<# Migrate SCCMApps-AirWatch Powershell Script Help

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
        -SCCMSiteCode "PAL:" `
        -AWServer "https://mondecorp.ssdevrd.com" `
        -userName "tkent" `
        -password "SecurePassword" `
        -tenantAPIKey "iVvHQnSXpX5elicaZPaIlQ8hCe5C/kw21K3glhZ+g/g=" `
        -groupID "652" `
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

Write-Verbose "-- Command Line Parameters --"
Write-Verbose ("Site Code: " + $SCCMSiteCode)
Write-Verbose ("Site Code: " + $AWServer)
Write-Verbose ("UserName: " + $userName)
Write-Verbose ("Password: " + $password)
Write-Verbose ("Tenant API Key: " + $tenantAPIKey)
Write-Verbose ("Endpoint URL: " + $groupID)
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

    [hashtable]$AirWatchProperties = @{}

    # Extract top level app properties
    $ApplicationName = $SDMPackageXML.AppMgmtDigest.Application.Title.InnerText
    $AirWatchProperties.Add("ApplicationName", $ApplicationName)
    $AirWatchProperties.Add("Description", $SDMPackageXML.AppMgmtDigest.Application.Description.InnerText)
    $AirWatchProperties.Add("Developer", $SDMPackageXML.AppMgmtDigest.Application.Publisher.InnerText)
    $AirWatchProperties.Add("ActualFileVersion", $SDMPackageXML.AppMgmtDigest.Application.SoftwareVersion.InnerText)

    # Get the first deployment method of multiple.
    $currentDeployment = $SDMPackageXML.AppMgmtDigest.DeploymentType | Select-Object -First 1

    # Map Install actions section to the corresponding AW properties
    $AirWatchProperties.Add("InstallCommand", ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "InstallCommandLine"}).InnerText)
    $AirWatchProperties.Add("InstallerRebootExitCode", ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "RebootExitCodes"}).InnerText)
    $AirWatchProperties.Add("InstallerSuccessExitCode", ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "SuccessExitCodes"}).InnerText)
    $AirWatchProperties.Add("DeviceRestart", ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "RequiresReboot"}).InnerText)
    $AirWatchProperties.Add("InstallTimeoutInMinutes", ($currentDeployment.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "ExecuteTime"}).InnerText)

    # Only set Uninstall command if present
    if(($currentDeployment.Installer.UninstallAction.Args.Arg | ? {$_.Name -eq "InstallCommandLine"}).InnerText -eq $null)
    {
        $AirWatchProperties.Add("UninstallCommandLine","An Uninstall Command is not setup in SCCM. Please update this field")
    }
    else
    {
        $AirWatchProperties.Add("UninstallCommandLine", ($currentDeployment.Installer.UninstallAction.Args.Arg | ? {$_.Name -eq "InstallCommandLine"}).InnerText)
    }


    #Set Default Install Context and modify if the Package context is System
    $AirWatchProperties.Add("InstallContext", "User")
        If(($SDMPackageXML.AppMgmtDigest.DeploymentType.Installer.InstallAction.Args.Arg | ? {$_.Name -eq "ExecutionContext"}).InnerText -eq "System")
    {
        $AirWatchProperties.Set_Item("InstallContext", "Device")
    }

    # Switch the file generation based on Deployment Technology. Script deployment files are zipped up into a single file.
    switch ($currentDeployment.Technology)
    {
        "MSI"
                {
                    $source = $currentDeployment.Installer.Contents.Content.Location
                    $file = ($currentDeployment.Installer.Contents.Content.File | ? {$_.Name -like "*.msi"}).Name
                    $uploadFilePath = $source + $file

                    Write-Verbose -Message "Adding file path to properties - $($uploadFilePath)"
                    $AirWatchProperties.Add("FilePath", $uploadFilePath)
                    $AirWatchProperties.Add("UploadFileName", $(Split-Path $uploadFilePath -Leaf))
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
                    $AirWatchProperties.Add("FilePath", $uploadFilePath)
                    $AirWatchProperties.Add("UploadFileName", $(Split-Path $uploadFilePath -Leaf))
                }
    }

    # Get the application identifier from the Enhanced Detection Method

    if(($currentDeployment.Installer.DetectAction.Args.Arg | ? {$_.Name -eq "MethodBody"}).InnerText -eq $null)
    {
        $AirWatchProperties.Add("InstallApplicationIdentifier", "No Product Code Found")
    }
    else
    {
        [xml] $enhancedDetectionMethodXML = ($currentDeployment.Installer.DetectAction.Args.Arg | ? {$_.Name -eq "MethodBody"}).InnerText
        $InstallApplicationIdentifier = $enhancedDetectionMethodXML.EnhancedDetectionMethod.Settings.MSI.ProductCode
        $AirWatchProperties.Add("InstallApplicationIdentifier", $InstallApplicationIdentifier)
    }

    # Add addition keys and values if we have them
    $AirWatchProperties.Add("BlobId", $null)
    $AirWatchProperties.Add("LocationGroupId", $groupID)

    Write-Verbose("---------- AW Properties ----------")
    Write-Host $AirWatchProperties | Out-String
    Write-Verbose("------------------------------")
    Write-Verbose("")

    Return $AirWatchProperties
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
		$awProperties
	)

    # Map all table values to the AirWatch JSON format
    $applicationProperties = @{
        ApplicationName = $awProperties.ApplicationName
	    AutoUpdateVersion = 'true'
	    BlobId = $awProperties.BlobID
	    DeploymentOptions = @{
		    WhenToInstall = @{
			    DiskSpaceRequiredInKb = 1
			    DevicePowerRequired= 2
			    RamRequiredInMb= 3
		    }
		    HowToInstall= @{
			    AdminPrivileges = "true"
			    DeviceRestart = "DoNotRestart"
			    InstallCommand = $awProperties.InstallCommand
			    InstallContext = $awProperties.InstallContext
			    InstallTimeoutInMinutes = $awProperties.InstallTimeoutInMinutes
			    InstallerRebootExitCode = $awProperties.InstallerRebootExitCode
			    InstallerSuccessExitCode = $awProperties.InstallerSuccessExitCode
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
                        ApplicationIdentifier = $awProperties.InstallApplicationIdentifier
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
				    UninstallCommand = $awProperties.UninstallCommandLine
			    }
		    }
	    }
	    Description = $awProperties.Description
	    Developer = $awProperties.Developer
	    DeveloperEmail = ""
	    DeveloperPhone = ""
	    DeviceType = 12
	    EnableProvisioning = "false"
	    FileName = $awProperties.UploadFileName
	    IsDependencyFile = "false"
	    LocationGroupId = $awProperties.LocationGroupId
	    MsiDeploymentParamModel = @{
		    CommandLineArguments = $awProperties.InstallCommand
		    InstallTimeoutInMinutes = $awProperties.InstallTimeoutInMinutes
		    RetryCount = 3
		    RetryIntervalInMinutes = 5
	    }
	    PushMode = 0
	    SupportEmail = ""
	    SupportPhone = ""
	    SupportedModels = @{
		    Model = @(@{
			    ApplicationId = 704
                ModelName = "Desktop"
			    ModelId = 50
		    })
	    }
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

#endregion

#region UI
# TODO - Use this instead of the block below in Main
Function Setup-UI {
    Param(
        $applications
    )

    # Start Drawing Form. The form has some issues depending on the screen resolution. #Needs to be updated
    $MainForm = New-Object System.Windows.Forms.Form
    $MainForm.Text = "Application Import"
    $MainForm.Size = New-Object System.Drawing.Size(450, 300)
    $MainForm.StartPosition = "CenterScreen"
    $MainForm.ShowIcon = $false

    $HeadingLabel = New-Object System.Windows.Forms.Label
    $HeadingLabel.Location = New-Object System.Drawing.Point(13,8)

    $HeadingLabel.Size = New-Object System.Drawing.Size($($MainForm.Width - 40), 15)
    $HeadingLabel.Text = "Select Apps to Import"
    $HeadingLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
    $MainForm.Controls.Add($HeadingLabel)

    $AppsListBox = New-Object System.Windows.Forms.CheckedListbox
    $AppsListBox.Location = New-Object System.Drawing.Size(13,22)
    $AppsListBox.Width = ($MainForm.Width - 40)
    $AppsListBox.Height = $($MainForm.Height - 100)
    $AppsListBox.AutoSize = $True
    $AppsListBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(($MainForm.Width - 105), ($MainForm.Height - 75))
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $OKButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $MainForm.AcceptButton = $OKButton
    $MainForm.Controls.Add($OKButton)

    $CancelButton1 = New-Object System.Windows.Forms.Button
    $CancelButton1.Location = New-Object System.Drawing.Point(($MainForm.Width - 190), ($MainForm.Height - 75))
    $CancelButton1.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton1.Text = "Cancel"
    $CancelButton1.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $CancelButton1.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $MainForm.CancelButton = $CancelButton1
    $MainForm.Controls.Add($CancelButton1)

    ##Add items to form
    foreach($Application in $Applications)
    {
        [void] $AppsListBox.Items.Add($Application)
    }

    #Display form to Admin
    $MainForm.Controls.Add($AppsListBox)
    $MainForm.Topmost = $True

    Return $MainForm
}
#endregion

#region MAIN
Function Main {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module

    Set-Location $SCCMSiteCode # Set the current location to be the site code.

    ##Progress bar
    Write-Progress -Activity "Application Export" -Status "Starting Script" -PercentComplete 10

    ##Get applicaion list via WMI
    ##$Applications = Get-WMIObject -ComputerName $SCCMServer -Namespace Root\SMS\Site_$SCCMSiteCode -Class "SMS_Application" | Select -unique LocalizedDisplayName | sort LocalizedDisplayName
    $Applications = Get-CMApplication | Select LocalizedDisplayName | sort LocalizedDisplayName

    ##Application Import Selection Form
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $UI = Setup-UI -applications $Applications
    $result = $UI.ShowDialog()

    # If a valid input is selected then set Application else quit
    if ($result1 -eq [System.Windows.Forms.DialogResult]::OK) {
        $SelectedApps = $form.Controls[3].CheckedItems
        Write-Host "Selected:: $SelectedApps"
    } else {
        exit
    }


    ##Progress bar
    Write-Progress -Activity "Application Export" `
        -Status "Searching for applications" `
	    -PercentComplete 30

    Foreach($App in $SelectedApps) {
        #Parse the Deployment details of the Selected application and deserialize.
        $selectedAppObject = Get-CMApplication -Name $App
        [xml]$SDMPackageXML = $selectedAppObject.SDMPackageXML

        ##Progress bar
        Write-Progress -Activity "Application Export" -Status "Finalizing" -PercentComplete 40

        #Extract the hashtable returned from the function
        $appProperties = @{}
        $appProperties = $(Extract-PackageProperties -SDMPackageXML $SDMPackageXML)

        #Generate Auth Headers from username and password
        $deviceListURI = $baseURL + $bulkDeviceEndpoint
        $restUserName = Create-BasicAuthHeader -username $userName -password $password

        # Define Content Types and Accept Types
        $useJSON = "application/json"

        #Build Headers
        $headers = Create-Headers -authString $restUserName `
            -tenantCode $tenantAPIKey `
        	-acceptType $useJson `
        	-contentType $useJson

        # Extract Filename, configure Blob Upload API URL and invoke the API.
        $uploadFileName = Split-Path $appProperties.FilePath -leaf
        $networkFilePath = "Microsoft.Powershell.Core\FileSystem::$($appProperties.FilePath)"

        # Confirm that the app binary is reachable and exists
        if(Test-Path $networkFilePath) {
            $blobUploadResponse = Upload-Blob -airwatchServer $AWServer `
               -filename $uploadFileName `
        	    -filepath $networkFilePath `
        	    -groupID $groupID `
        	    -headers $headers

            ##Progress bar
            Write-Progress -Activity "Application Export" -Status "Finalizing" -PercentComplete 70

            # Extract Blob ID and store in the properties table.
            $blobID = [string]$blobUploadResponse.Value
            # This resets the properties to a hashtable since powershell returns an array from the function
            $appProperties = $appProperties[1]

            $appProperties["BlobId"] = $blobID

            ##Progress bar
            Write-Progress -Activity "Application Export" `
                -Status "Exporting $SelectedApplication" `
                -PercentComplete 80

            # Call function to map all properties from SCCM to AirWatch JSON.
            $awJson = Map-AppDetailsJson -awProperties $appProperties

            if($appProperties.BlobId -ne $null) {
                 # Save App/Finish Upload in AirWatch
                $webReturn = Save-App -awServer $AWServer `
                    -headers $headers `
                    -appDetails $awJson

                Write-Verbose -Message "Return from save $webReturn"
            } else {
                Write-Verbose -Message "Blob ID not in hashtable, unable to finish upload of  $SelectedApplication"
            }

        } else {
            Write-Output "Unable to reach app file path, $SelectedApplication not uploaded to AirWatch"
        }

        ##Progress bar
        Write-Progress -Activity "Application Export" `
            -Status "Export of $SelectedApplication Completed" `
            -PercentComplete 100

    } # End foreach

    Write-Output "End"
}
#endregion

#Calling Main
Main
