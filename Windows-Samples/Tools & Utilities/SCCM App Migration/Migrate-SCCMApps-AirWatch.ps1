<# Migrate SCCMApps-AirWatch Powershell Script Help
#Updated UninstallString Detection Logic - Chris Halstead chalstead@vmware.com
  .SYNOPSIS
    This Powershell script allows you to automatically migrate SCCM applications over to AirWatch for management from the AirWatch console.
    MUST RUN AS ADMIN
    MUST UPDATE SCCM SITECODE

  .DESCRIPTION
    When run, this script will prompt you to select an application for migration. It then parses through the deployment details of the
    application and pushes the application package to AirWatch. The script then maps all the deployment commands and settings over to the
    AirWatch application record. MSIs are ported over as-is. Script deployments are ported over as ZIP folders with the correct execution
    commands to unpack and apply them.

  .EXAMPLE

    .\Migrate-SCCMApps-AirWatch.ps1 `
        -SCCMSiteCode "SME:" `
        -AWServer "https://example.awmdm.com" `
        -userName "apiuser" `
        -password "SecurePassword" `
        -tenantAPIKey "APIKEY" `
        -groupID "111" `
        -Verbose

  .PARAMETER SCCMSiteCode
    The Site Code of the SCCM Server that the script can set the location to.

  .PARAMETER AWServer
    Server URL for the AirWatch API Server

  .PARAMETER userName
    An AirWatch account in the tenant is being queried.  This user must have the API role at a minimum.

  .PARAMETER password
    The password that is used by the user specified in the username parameter

  .PARAMETER tenantAPIKey
    This is the REST API key that is generated in the AirWatch Console.  You locate this key at All Settings -> Advanced -> API -> REST,
    and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access

  .PARAMETER groupID
    The groupID is the ID of the Organization Group where the apps will be migrated. The API key and admin credentials need to be authenticated
    at this Organization Group. The shorcut to getting this value is to navigate to https://<YOUR HOST>/AirWatch/#/AirWatch/OrganizationGroup/Details.
    The ID you are redirected to appears in the URL (7 in the following example). https://<YOUR HOST>/AirWatch/#/AirWatch/OrganizationGroup/Details/Index/7

#>

[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]$SCCMSiteCode,

        [Parameter(Mandatory=$True)]
        [string]$AWServer,

        [Parameter(Mandatory=$True)]
        [string]$userName,

        [Parameter(Mandatory=$True)]
        [string]$password,

        [Parameter(Mandatory=$True)]
        [string]$tenantAPIKey,

        [Parameter(Mandatory=$True)]
        [string]$groupID
)

#region 
### Script Variables ####
$OutputFolder = "$($PSScriptRoot)\App-Migration-Output"
$initialized = $false
#endregion

Write-Verbose "-- Command Line Parameters --"
Write-Verbose ("Site Code: " + $SCCMSiteCode)
Write-Verbose ("Site Code: " + $AWServer)
Write-Verbose ("UserName: " + $userName)
Write-Verbose ("Password: " + $password)
Write-Verbose ("Tenant API Key: " + $tenantAPIKey)
Write-Verbose ("Endpoint URL: " + $groupID)
Write-Verbose ("Working Directory: " + $OutputFolder)
Write-Verbose "-----------------------------"
Write-Verbose ""

#region SCCM Helpers
<#
  This method extracts specific properties from the SCCM deployment details and stores them in an AirWatch Properties table.
  Different deployment modes require different properties to be stored.
#>
Function Extract-PackageProperties {

    Param(
		[Parameter(Mandatory=$True)]
		[xml]$SDMPackageXML
	)

    [pscustomobject]$AppObject = New-Object PSObject

    # Extract top level app properties
    $ApplicationName = $SDMPackageXML.AppMgmtDigest.Application.Title.InnerText
    $AppObject |  Add-Member -MemberType NoteProperty -Name "ApplicationName"-Value $ApplicationName
    $AppObject |  Add-Member -MemberType NoteProperty -Name "Description"-Value $SDMPackageXML.AppMgmtDigest.Application.Description.InnerText
    $AppObject |  Add-Member -MemberType NoteProperty -Name "Developer"-Value $SDMPackageXML.AppMgmtDigest.Application.Publisher.InnerText
    $AppObject |  Add-Member -MemberType NoteProperty -Name "ActualFileVersion"-Value $SDMPackageXML.AppMgmtDigest.Application.SoftwareVersion.InnerText

    # Get the first deployment method of multiple.
    $currentDeployment = $SDMPackageXML.AppMgmtDigest.DeploymentType | Select-Object -First 1

    # Map Install actions section to the corresponding AW properties
    $AppObject |  Add-Member -MemberType NoteProperty -Name "InstallCommand"-Value ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "InstallCommandLine"}).InnerText
    $AppObject |  Add-Member -MemberType NoteProperty -Name "InstallerRebootExitCode"-Value ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "RebootExitCodes"}).InnerText
    $AppObject |  Add-Member -MemberType NoteProperty -Name "InstallerSuccessExitCode"-Value ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "SuccessExitCodes"}).InnerText
    $AppObject |  Add-Member -MemberType NoteProperty -Name "DeviceRestart"-Value ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "RequiresReboot"}).InnerText
    $AppObject |  Add-Member -MemberType NoteProperty -Name "InstallTimeoutInMinutes"-Value ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "ExecuteTime"}).InnerText
 
     # Only set Uninstall command if present
     #Updated 3/15/18 - Chris Halstead
    if(($currentDeployment.Installer.UninstallAction.Args.Arg | ? {$_.Name -eq “InstallCommandLine”}).InnerText -eq $null)
    {
        [string]$UninstallCommandLineString = “UninstallCommandLine”
        $AppObject | Add-Member -MemberType NoteProperty -Name $($UninstallCommandLineString) -Value “An Uninstall Command is not setup in SCCM. Please update this field”
    }
    else
    {
        $AppObject | Add-Member -MemberType NoteProperty -Name “UninstallCommandLine” -Value ($currentDeployment.Installer.UninstallAction.Args.Arg | ? {$_.Name -eq “InstallCommandLine”}).InnerText
    }

    #Set Default Install Context and modify if the Package context is System
    $AppObject |  Add-Member -MemberType NoteProperty -Name "InstallContext"-Value "User"
        If(($SDMPackageXML.AppMgmtDigest.DeploymentType.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "ExecutionContext"}).InnerText -eq "System")
    {
        $AppObject |  Add-Member -MemberType NoteProperty -Name "InstallContext" -Value "Device" -Force
    }

    # Switch the file generation based on Deployment Technology. Script deployment files are zipped up into a single file.
    switch ($currentDeployment.Technology)
    {
        "MSI"
                {
                    $source = $currentDeployment.Installer.Contents.Content.Location

                    # Although the deployment technology indicates a MSI file, sometimes it can be a .exe file, the "name like *.msi" check will fail
                    # and results in a empty filename. Simply removing the file type check fixes the problem.
                    $file = $currentDeployment.Installer.Contents.Content.File.Name

                    # In some cases the $source returns without the backslash, then the full file path is wrong.
                    $uploadFilePath = $source + '\' + $file

                    Write-Verbose -Message "Adding file path to properties - $($uploadFilePath)"
                    $AppObject |  Add-Member -MemberType NoteProperty -Name "FilePath"-Value $uploadFilePath
                    $AppObject |  Add-Member -MemberType NoteProperty -Name "UploadFileName"-Value $(Split-Path $uploadFilePath -Leaf)
                }
        "Script"
                {
                    #Zip Script deployments into a file for upload
                    $source = $currentDeployment.Installer.Contents.Content.Location
                    $parentFolder = ($source | Split-Path -Parent)
                    $folderName = ($source | Split-Path -Leaf)
                    $uploadFilePath = $parentFolder + "\$folderName.zip"
                    
                    #remove zip if already exists
                    If(Test-path $uploadFilePath) {Remove-item $uploadFilePath}
                    Add-Type -assembly "system.io.compression.filesystem"

                    try {
                        [io.compression.zipfile]::CreateFromDirectory($source, $uploadFilePath)
                    } catch {
                        "Unable to zip script file with error: $_"
                    }

                    $AppObject |  Add-Member -MemberType NoteProperty -Name "FilePath" -Value $uploadFilePath
                    $AppObject |  Add-Member -MemberType NoteProperty -Name "UploadFileName" -Value $(Split-Path $uploadFilePath -Leaf)
                }
       
    }


    # Get the application identifier by searching ProductCode arg in the deployment xml, if not found, set the value to be a "not null" string.
    # The previous code snippet will not set the value in some cases, which fails the AirWatch Begininstall API call.

    $argProductCode = ($currentDeployment.Installer.DetectAction.Args.Arg | ? {$_.Name -eq "ProductCode"}).InnerText

    [xml] $enhancedDetectionMethodXML = ($currentDeployment.Installer.DetectAction.Args.Arg | ? {$_.Name -eq "MethodBody"}).InnerText
    $argMethodBodyProductCode = $enhancedDetectionMethodXML.EnhancedDetectionMethod.Settings.MSI.ProductCode

    if ($argProductCode -ne $null)
    {
        $AppObject |  Add-Member -MemberType NoteProperty -Name "InstallApplicationIdentifier"-Value $argProductCode
    }
    elseif ($argMethodBodyProductCode -ne $null) 
    {
        $AppObject |  Add-Member -MemberType NoteProperty -Name "InstallApplicationIdentifier"-Value $argMethodBodyProductCode
    } 
    else 
    {
        $AppObject |  Add-Member -MemberType NoteProperty -Name "InstallApplicationIdentifier"-Value "No Product Code Found"
    }

    # Add addition keys and values if we have them
    $AppObject |  Add-Member -MemberType NoteProperty -Name "BlobId"-Value $null
    $AppObject |  Add-Member -MemberType NoteProperty -Name "LocationGroupId"-Value $groupID

    Return $AppObject
}
#endregion

#region AirWatch API
<#
  This method maps all the AirWatch Properties extracked and stored in a table to the corresponding JSON value in the AirWatch
  API body.
#>
Function Map-AppDetailsJSON {

    Param(
		[Parameter(Mandatory=$True)]
		$appDetails
	)

    # Setup DeviceType and SupportedModels based on AW Version
    if ([System.Version]$appDetails.AirWatchVersion -ge [System.Version]"9.2.0.0") {
        Write-Log -logString "AirWatch version $($appDetails.AirWatchVersion) is greater than 9.2, using Modelname Desktop"
        $appDetails | Add-Member -MemberType NoteProperty -Name "DeviceType" -Value 12
        $appDetails | Add-Member -MemberType NoteProperty -Name "SupportedModels" -Value @{
            Model = @(@{
                ModelId = 83
                ModelName = "Desktop"
            })
        }
    }
    else {
        Write-Log -logString "AirWatch version $($appDetails.AirWatchVersion) is less than 9.2, using Modelname Windows 10"
        $appDetails | Add-Member -MemberType NoteProperty -Name "DeviceType" -Value 12
        $appDetails | Add-Member -MemberType NoteProperty -Name "SupportedModels" -Value @{
            Model = @(@{
                ModelId = 50
                ModelName = "Windows 10"
            })
        }
    }

    # Map all table values to the AirWatch JSON format
    $applicationProperties = @{
        ApplicationName = $appDetails.ApplicationName
	    AutoUpdateVersion = 'true'
	    BlobId = $appDetails.BlobID
	    DeploymentOptions = @{
		    WhenToInstall = @{
			    DiskSpaceRequiredInKb = 1
			    DevicePowerRequired= 2
			    RamRequiredInMb= 3
		    }
		    HowToInstall= @{
			    AdminPrivileges = "true"
			    DeviceRestart = "DoNotRestart"
			    InstallCommand = $appDetails.InstallCommand
			    InstallContext = $appDetails.InstallContext
			    InstallTimeoutInMinutes = $appDetails.InstallTimeoutInMinutes
			    InstallerRebootExitCode = $appDetails.InstallerRebootExitCode
			    InstallerSuccessExitCode = $appDetails.InstallerSuccessExitCode
			    RetryCount = 3
			    RetryIntervalInMinutes = 5
		    }
		    WhenToCallInstallComplete = @{
			    UseAdditionalCriteria = "false"
			    IdentifyApplicationBy = "DefiningCriteria"
                CriteriaList = @(@{
                    CriteriaType = "AppExists"
				    LogicalCondition = "End"
                    AppCriteria = @{
                        ApplicationIdentifier = $appDetails.InstallApplicationIdentifier
                        VersionCondition = "Any"
                    }
                })
			    CustomScript = @{
				    ScriptType = "Unknown"
				    CommandToRunTheScript = "Text value"
				    CustomScriptFileBlodId = 3
				    SuccessExitCode = 1
			    }
		    }
	    }
	    FilesOptions = @{
		    ApplicationUnInstallProcess = @{
			    UseCustomScript = "true"
			    CustomScript =  @{
				    CustomScriptType = "Input"
				    UninstallCommand = $appDetails.UninstallCommandLine
			    }
		    }
	    }
	    Description = $appDetails.Description
	    Developer = $appDetails.Developer
	    DeveloperEmail = ""
	    DeveloperPhone = ""
	    DeviceType = $appDetails.DeviceType
	    EnableProvisioning = "false"
	    FileName = $appDetails.UploadFileName
	    IsDependencyFile = "false"
	    LocationGroupId = $appDetails.LocationGroupId
	    MsiDeploymentParamModel = @{
		    CommandLineArguments = $appDetails.InstallCommand
		    InstallTimeoutInMinutes = $appDetails.InstallTimeoutInMinutes
		    RetryCount = 3
		    RetryIntervalInMinutes = 5
	    }
	    PushMode = 0
	    SupportEmail = ""
	    SupportPhone = ""
	    SupportedModels = $appDetails.SupportedModels
	    SupportedProcessorArchitecture = "x86"
    }

    $json = $applicationProperties | ConvertTo-Json -Depth 10
    Write-Verbose "------- JSON to Post---------"
    Write-Verbose $json
    Write-Verbose "-----------------------------"
    Write-Verbose ""

    Return $json
}

<#
  This implementation uses Basic authentication.  See "Client side" at https://en.wikipedia.org/wiki/Basic_access_authentication for a description
  of this implementation.
#>
Function Create-BasicAuthHeader {

	Param(
		[Parameter(Mandatory=$True)]
		[string]$username,
		[Parameter(Mandatory=$True)]
		[string]$password)

	$combined = $username + ":" + $password
	$encoding = [System.Text.Encoding]::ASCII.GetBytes($combined)
	$encodedString = [Convert]::ToBase64String($encoding)

	Return "Basic " + $encodedString
}

<#
  This method builds the headers for the REST API calls being made to the AirWatch Server.
#>
Function Create-Headers {

    Param(
		[Parameter(Mandatory=$True)]
		[string]$authString,
		[Parameter(Mandatory=$True)]
		[string]$tenantCode,
		[Parameter(Mandatory=$True)]
        [string]$acceptType,
		[Parameter(Mandatory=$True)]
		[string]$contentType
    )


    $header = @{"Authorization" = $authString; "aw-tenant-code" = $tenantCode; "Accept" = $acceptType.ToString(); "Content-Type" = $contentType.ToString()}

    Return $header
}

<#
    This Function uploads the app file to the AirWatch server
#>
Function Upload-Blob {
  Param(
	  [Parameter(Mandatory=$True)]
	  [String] $airwatchServer,
	  [Parameter(Mandatory=$True)]
      [String] $filename,
	  [Parameter(Mandatory=$True)]
      [String] $filePath,
	  [Parameter(Mandatory=$True)]
      [String] $groupID,
	  [Parameter(Mandatory=$True)]
      [hashtable] $headers
  )

  $url = Create-BlobURL -baseURL $airwatchServer -filename $filename -groupID $groupID

  Write-Verbose "File Path $filePath"

  $response = Invoke-RestMethod -Method Post -Uri $url.ToString() -Headers $headers -InFile $filePath

  Write-Verbose "Response 'Upload Blob' :: $response"

  Return $response
}

<#
  Creates the url for the blob upload
#>
Function Create-BlobURL {
    Param(
		[Parameter(Mandatory=$True)]
		[String] $baseURL,
		[Parameter(Mandatory=$True)]
        [String] $filename,
		[Parameter(Mandatory=$True)]
        [String] $groupID
	)
    $url = "$baseURL/api/mam/blobs/uploadblob?filename=$filename&organizationgroupid=$groupID"

    Return $url
}

Function Save-App {
	Param(
		[Parameter(Mandatory=$True)]
		[String] $awServer,
		[Parameter(Mandatory=$True)]
		[hashtable] $headers,
		[Parameter(Mandatory=$True)]
		$appDetails
	)

	$url = "$awServer/api/v1/mam/apps/internal/begininstall"

    try {
        $response = Invoke-RestMethod -Method Post -Uri $url.ToString() -Headers $headers -Body $appDetails
    } catch {
         Write-Verbose -Message "Save app failed :: $PSItem"
    }


    Write-Verbose "Response 'Save App' :: $response"

	Return $response
}

function Get-AirWatchVersion {
    Param(
        [Parameter(Mandatory=$True)]
        [hashtable] $headers
    )
    
    try {
        $endpoint = "$awServer/api/system/info"
	    $response = Invoke-RestMethod -Method Get -Uri $endpoint.ToString() -Headers $headers
        $version = $response.ProductVersion

    }
    catch [System.Net.WebException] {
        $response = $_.Exception.Response | ConvertTo-Json
        Write-Verbose "Querying AirWatch version ($endpoint) Failed! Exception :: $($_.Exception.Message)"
        Write-Verbose "RESPONSE :: $($_.Exception.Response | ConvertTo-Json)"
    } 
    catch {
        $response = $null
        Write-Verbose "Get AirWatch Version failed :: $PSItem"
    }

    Write-Verbose "Get AirWatch Version response :: $response"
    return $version;
}
#endregion

#region UTIL
function Initialize {
    Param(
        $OutputFolder
    )

    Write-Log -logString "Importing ConfigurationManager.psd1"
    #Import-Module "$($env:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"

    Write-Host "Initializing"

    Write-Log "Checking if $($OutputFolder) exists"
    if(!$(Test-Path -Path $OutputFolder)) {
        Write-Log "Creating $($OutputFolder)"
        New-Item -Path $OutputFolder -ItemType "Directory" | Out-Null
    }
}

function Write-Log {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$logString
    )

    $logDate = Get-Date -UFormat "%y-%m-%d"
    $dateTime = (Get-Date).toString()
    $logPath = "$($OutputFolder)\Logs"

    if(!(Test-Path -Path $logPath)) { New-Item -Path $logPath -ItemType Directory | Out-Null }

    $logFile = "$($logPath)\log-$($logDate).txt"
    "$($dateTime) | $($logString)" | Out-File -FilePath $logFile -Append
}
#endregion

#region Import Apps To AirWatch
function Get-AppsFromReport {
    Write-Log "Showing UI for CSV selection"
    $csv = Get-ChildItem -Path $OutputFolder -Filter "*.csv" | Select Name, FullName | Out-GridView -OutputMode Single -Title "Select App CSV to Export"
    
    Write-Log "Fetching details from csv at $($csv.FullName)"
    $apps = Import-Csv -Path $csv.FullName

    Write-Log "Retrieved $($apps.count) Apps from csv"

    return $apps
}

function Migrate-AppsToAirWatch {
    # Setup API Info
    #Setup header information
    $restUserName = Create-BasicAuthHeader -username $userName -password $password
    $useJSON = "application/json"
    
    #Build Headers for APIs
    $headers = Create-Headers -authString $restUserName `
        -tenantCode $tenantAPIKey `
        -acceptType $useJson `
        -contentType $useJson

    #Retrieve AW version
    $airwatchVersion = Get-AirWatchVersion -headers $headers
    Write-Log "AirWatch version is $($airWatchVersion)"

    #Get Apps
    $apps = Get-AppsFromReport
    #Loop Through Apps
    foreach($app in $apps) {
        Write-Host "Exporting $($app.ApplicationName)"
        
        # Add additional properties
        $app | Add-Member -MemberType NoteProperty -Name "AirWatchVersion" -Value $airwatchVersion
        
        # Fetch App filename and path
        $uploadFileName = $app.UploadFileName
        $networkFilePath = "Microsoft.Powershell.Core\FileSystem::$($app.FilePath)"
        
        # Upload Blob
        if(Test-Path $networkFilePath) {
            $blobUploadResponse = Upload-Blob -airwatchServer $AWServer `
               -filename $uploadFileName `
        	    -filepath $networkFilePath `
        	    -groupID $groupID `
                -headers $headers

            # Extract Blob ID and store in the properties table.
            $blobID = [string]$blobUploadResponse.Value
            $app.BlobId = $blobID

            # Map App details to Json
            $awJson = Map-AppDetailsJson -appDetails $app

            # Save App
            if($app.BlobId -ne $null) {
                # Save App/Finish Upload in AirWatch
               $webReturn = Save-App -awServer $AWServer `
                   -headers $headers `
                   -appDetails $awJson

               Write-Verbose -Message "Return from save $webReturn"
           } else {
               Write-Verbose -Message "Blob ID not in hashtable, unable to finish upload of  $($app.ApplicationName)"
           }

        } else {
            Write-Output "Unable to reach app file path, $($app.ApplicationName) not uploaded to AirWatch"
        }
     
    }
    
}
#endregion

#region Generate App Export Report
function Create-AppExportReport {

    Param($OutputFolder)


    #Get the Apps
    Write-Host "Fetching Apps from SCCM...this may take a few minutes"
    Write-Log -logString "Running Get-CMApplication to retrieve apps from SCCM"
    $sccmApps = Get-CMApplication
    
    Write-Log -logString "Fetched $($sccmApps.Count) from SCCM"
    Write-Host "Fetched $($sccmApps.Count) from SCCM"
    
    #Create new PSObject for Each App
    Write-Host "Processing Apps from SCCM"
    $apps = @()
    $i = 1 #Holds current count for percent indicator
    
    foreach($app in $sccmApps) {
        Write-Progress -Activity "Exporting App Data" -Status "Processing $($app.LocalizedDisplayName)" -PercentComplete ($i / $sccmApps.Count * 100)
        Write-Log -logString "Processing $($app.LocalizedDisplayName) :: $($i) of $($sccmApps.Count)"
        [pscustomobject]$appObject = Extract-PackageProperties -SDMPackageXML $app.SDMPackageXML
        
        
        #Add apps to larger array
        $apps += $appObject
        $i += 1
    }

    Write-Progress -Activity "Exporting App Data" -Completed

    $DateStr = (Get-Date).ToString("yyyy-MM-dd")

    #Export to csv
    $reportPath = "$($OutputFolder)\$($DateStr)-SCCM-Apps-Report.csv"

    Write-Log -logString "Exporting apps to csv at $($reportPath)"
    Write-Host "Exporting apps to csv at $($reportPath)"
    $apps | Export-Csv -Path $reportPath -NoTypeInformation
    
}
#endregion

#region MAIN
Function Main {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module

    Set-Location $SCCMSiteCode # Set the current location to be the site code.
    
    Initialize -OutputFolder $OutputFolder

    Write-Host "`nChoose a Task:"
    Write-Host "================"
    Write-Host "(1) Generate MSI and EXE App Report"
    Write-Host "(2) Migrate Apps to AirWatch"
    Write-Host "(0) END"

    $selection = Read-Host -Prompt "Selection"

    switch($selection) {
        "1" {
            Write-Host "Generating MSI and EXE App Report"
            Write-Log -logString "Generating MSI and EXE App Report"
            Create-AppExportReport -OutputFolder $OutputFolder
        }

        "2" {
            Write-Host "Migrating Apps to AirWatch"
            Write-Log -logString "Migrating Apps to AirWatch"
            Migrate-AppsToAirWatch
        }

        "0" { }

        default {
            Write-Host "Invalid choice! Please choose a value from the above list."
        }
    }

    if($selection -ne "0") {
        MAIN
    }

}

#endregion

#Calling Main
Main
