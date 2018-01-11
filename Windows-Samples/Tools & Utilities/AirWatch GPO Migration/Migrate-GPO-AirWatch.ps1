<# Migrate GPOs to AirWatch Powershell Script Help

  .SYNOPSIS
    This Powershell script allows you to capture and upload both new or existing GPO backups to AirWatch to easily deploy and apply policies to your managed devices.
    MUST RUN AS ADMIN
    MUST DOWNLOAD AND INCLUDE THE MICROSOFT SECURITY COMPLIANCE TOOLKIT IN THE ROOT FOLDER OF THE PROJECT (https://www.microsoft.com/en-us/download/details.aspx?id=55319)
    MUST USE AIRWATCH ACCOUNT WITH API ACCESS
    API SUPPORT ONLY ON AIRWATCH 9.2.3.0 AND NEWER
   
  .DESCRIPTION
    When run, this script will prompt you to view, capture, or upload GPO backups to AirWatch.

    Viewing & Capturing GPOs:
    GPO backups are captured and stored within the GPO Backups folder in the project files.  In addition to capturing GPO backups, you can
    also copy or move existing GPO backups to this GPO Backups folder to easily upload these to AirWatch.

    Uploading GPOs:
    When deploying packages to AirWatch, you will need AirWatch Admin credentials to authenticate against the AirWatch APIs.  This AirWatch
    Admin needs access to the Organization Group you are deploying the package to.  Once the packages are uploaded to AirWatch, you will need
    to assign them to the desired devices within the AirWatch Console.
    When selecting GPOs backups to upload, you can select multiple GPOs by holding Shift or Ctrl when clicking.  GPOs will be applied on machines
    in the order in which they were selected.

  .EXAMPLE

    .\Migrate-GPO-AirWatch.ps1 `
        -awServer "https://mondecorp.ssdevrd.com" `
        -awUsername "tkent" `
        -awPassword "SecurePassword" `
        -awTenantAPIKey "iVvHQnSXpX5elicaZPaIlQ8hCe5C/kw21K3glhZ+g/g=" `
        -awGroupID "652" `
        -Verbose

  .PARAMETER awServer
    Server URL for the AirWatch API Server

  .PARAMETER awUsername
    The username of an AirWatch account being used in the target AirWatch server.  This user must have a role that allows API access.

  .PARAMETER awPassword
    The password of the AirWatch account specified by the awUsername parameter.

  .PARAMETER awTenantAPIKey
    This is the REST API key that is generated in the AirWatch Console.  You locate this key at All Settings -> Advanced -> API -> REST,
    and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access, which is
    available at Customer type Organization Groups

  .PARAMETER awGroupID
    The groupID is the ID of the Organization Group where the GPOs will be uploaded. The awTenantAPIKey parameter and admin credentials
    need to be authenticated at this Organization Group. 
    The shorcut to getting this value is to navigate to https://<YOUR HOST>/AirWatch/#/AirWatch/OrganizationGroup/Details.
    The ID you are redirected to appears in the URL (7 in the following example). https://<YOUR HOST>/AirWatch/#/AirWatch/OrganizationGroup/Details/Index/7

#>

[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
		[string]$awServer,
        [Parameter(Mandatory=$False)]
        [string]$awUsername,
        [Parameter(Mandatory=$False)]
        [string]$awPassword,
        [Parameter(Mandatory=$False)]
        [string]$awTenantAPIKey,
        [Parameter(Mandatory=$False)]
        [string]$awGroupID
)

Write-Verbose "---- Command Line Parameters ----"
Write-Verbose "awServer: '$awServer'"
Write-Verbose "awTenantAPIKey: '$awTenantAPIKey'"
Write-Verbose "awUsername: '$awUsername'"
Write-Verbose "awPassword: '$awPassword'"
Write-Verbose "awGroupID: '$awGroupID'"
Write-Verbose "---------------------------------`n"

# Paths
$basePath = $PSScriptRoot
$backupFolder = "$basePath\GPO Backups"
$uploadFolder = "$basePath\GPO Uploads"
$lgpoPath = "$basePath\LGPO.exe"

# Supporting Files
$supportFilePath = "$basePath\Supporting Files"
$deployPackageScriptFilename = "DeployPackage.ps1"
$deployPackageScriptFilepath = "$supportFilePath\$deployPackageScriptFilename"
$confirmPackageScriptFilename = "LGPOConfirmPackageInstall.ps1"
$confirmPackageScriptFilepath = "$supportFilePath\$confirmPackageScriptFilename"
$loggingScriptFilename = "Logging.ps1"
$loggingScriptFilepath = "$supportFilePath\$loggingScriptFilename"

# State Vars
$initialized = $false
$apiAuthenticated = $false

#region LGPO Commands
<#
    Display a list of GPO backups that currently reside in the GPO Backup folder
    to a grid view
#>
function Select-GPOBackups {
    Param(
        [Parameter(Mandatory=$False)]
		[string]$title = "Select GPO Backups for Upload"
    )

    # Query the list of GPOs held in our GPO Backup folder and display them to the user in a grid
    $gpoBackups = @(Get-GPOBackups)
    if ($gpoBackups.Count -ge 1) {
        $gpo = @($gpoBackups | Out-GridView -OutputMode Multiple -Title $title)
    }
    else {
        Write-Warning "No GPO backups or captures exist within '$backupFolder'!"
        Write-Warning "Copy existing GPO backups into the above directory or capture a GPO backup using this tool first!"
    }

    return $gpo
}

<#
    Query and return a list of valid GPO Backups that are contained within the GPO Backup folder
#>
function Get-GPOBackups {
    # Query a list of paths for our GPO Backups from the GPO Backup folder
    $gpoPaths = Get-ChildItem -Path "$backupFolder" | Where-Object { $_.PSIsContainer } | ForEach-Object { $_.FullName }

    # Build a list of objects for each GPO Backup contained in the GPO Backups folder if it contains the necessary information
    $GPOs = New-Object System.Collections.Generic.List[System.Object]
    foreach ($gpoPath in $gpoPaths) {
        [xml]$a = Get-Content -Path "$gpoPath\bkupInfo.xml"
		$name = If ($a.BackupInst.BackupTime.InnerText -eq $null) { $a.BackupInst.GPODisplayName } Else { $a.BackupInst.GPODisplayName.InnerText }
		$time = If ($a.BackupInst.BackupTime.InnerText -eq $null) { $a.BackupInst.BackupTime } Else { $a.BackupInst.BackupTime.InnerText }
		$id = If ($a.BackupInst.BackupTime.InnerText -eq $null) { $a.BackupInst.ID } Else { $a.BackupInst.ID.InnerText }
        
        $gpoProperty = [ordered]@{
            name = $name
            time = $time
            id = $id
            filename = ($gpoPath | Split-Path -Leaf)
            path = $gpoPath
        }
        $GPOs.Add($(New-Object -TypeName psobject -Property $gpoProperty))
    }
    return $GPOs | Sort-Object -Property Name, Time
}

<#
    Builds the .zip package for the selected GPO backups that will be uploaded to AirWatch via APIs.
    Includes the necessary .ps1 scripts and accompanying files to import the GPOs on the assigned devices.
#>
function Build-GPOPackage {
    Param(
		[Parameter(Mandatory=$True)]
		[System.Collections.Generic.List[System.Object]]$GPOs
	)
    
    # Include all GPO Backup folders that were selected
    $targets = New-Object System.Collections.Generic.List[System.Object]
    $GPOs | ForEach-Object -Process {
        $targets.Add($_.path)
    }

    # Include the LGPO.exe file
    $targets.Add($lgpoPath)

    # Build the supporting ps1 and csv files and include these in the .zip targets
    $deployPackageCsvPath = Build-DeployPackageCSV -GPOs $GPOs
    $targets.Add($deployPackageCsvPath)
    $targets.Add($deployPackageScriptFilepath)
    $targets.Add($loggingScriptFilepath)
    
    # Build .zip file for upload
    $filename = "$(Get-GPOPolicyName).zip"
    $filepath = "$uploadFolder\$filename"
    
    # Delete the file if it already exists
    if (Test-Path -Path $filepath) { Remove-Item $filepath }

    try {
        # Compress the target files and create the gpoPackage object
        $output = Compress-Archive -LiteralPath $targets -CompressionLevel Optimal -DestinationPath $filepath -Force
        $gpoPackage = New-Object -TypeName psobject -Property @{
            fileIO = $output
            filename = $filename
            filepath = $filepath
        }
    }
    catch {
        Write-Error "Build-GPOPackage encountered an error :: $PSItem"
    }
    
    # Delete the supporting files that were packaged in the .zip
    if (Test-Path -Path $deployPackageCsvPath) { Remove-Item $deployPackageCsvPath }

    return $gpoPackage
}

<#
    Capture the local GPO policies using LGPO.exe
#>
function Capture-LocalGPO {
    # Send a command to LGPO.exe to capture the local GPOs
    Write-Progress -Activity "Capture Local GPOs" -Status "Capturing Local GPOs" -PercentComplete 33
    $name = Get-GPOPolicyName
    $params = "/b ""$backupFolder"" /n ""$name"""
    Process-LGPOCommand -params $params

    # Confirm if the GPO was successfully captured by checking it exists in our backups
    Write-Progress -Activity "Capture Local GPOs" -Status "Confirming Capture" -PercentComplete 66
    $capturedGPO = New-Object -TypeName psobject -Property @{
        name = $name
        success = $(Get-GPOBackups).name -contains $name
    }

    Write-Progress -Activity "Capture Local GPOs" -Status "Capture Finished" -PercentComplete 100
    Write-Progress -Activity "Capture Local GPOs" -Completed
    return $capturedGPO
}

<#
    Send a command to LGPO.exe 
#>
function Process-LGPOCommand {
    Param(
		[Parameter(Mandatory=$True)]
		[string]$params
	)

    return Start-Process $lgpoPath $params -Verb runas -Wait -WindowStyle Hidden
}

<#
    Create a GPO Policy Name based on the Machine Name and the current timestamp
#>
function Get-GPOPolicyName {
    return "GPO $([system.environment]::MachineName) $(Get-Date -UFormat "%m-%d-%Y %I-%M%p" )"
}
#endregion

#region AirWatch APIs
<#
    Uploads the .zip package and accompanying When To Call Install Complete .ps1 script as blobs to
    the AirWatch Console, then publishes the application.
#>
function Upload-GPOsToAirWatch {
    # Select GPO(s) to upload
    Write-Host "`nBeginning Upload-GPOsToAirWatch. Select the GPO(s) from the popup to upload."
    $GPOs = Select-GPOBackups
    if ($GPOs -eq $null) {
        return Write-Host "No GPO backups were selected to upload - quitting!"
    }
    
    # Build .zip package for GPO(s), LGPO.exe and ps1
    Write-Progress -Activity "GPO Migration" -Status "Building GPO Package" -PercentComplete 10
    $gpoPackage = Build-GPOPackage -GPOs $GPOs
    if ($gpoPackage -eq $null) {
        return Write-Host "An error occurred when attempting to build the GPO zip package - quitting! Check the output for more details."
    }
    
    # Upload zip Blob to AW
    Write-Host "Uploading .zip package to AirWatch..."
    Write-Progress -Activity "GPO Migration" -Status "Uploading GPO Package to AirWatch" -PercentComplete 25
    $uploadBlobResponse = Upload-Blob -filename $gpoPackage.filename -filepath $gpoPackage.filepath
    if ($uploadBlobResponse -eq $null -or $uploadBlobResponse.uuid -eq $null) {
        Write-Progress -Activity "GPO Migration" -Completed
        return Write-Host "An error occurred when attempting to upload the .zip package to AirWatch - quitting! Check the output for more details."
    }

    # Upload PS1 Blob to AW
    Write-Host "Uploading .ps1 script to AirWatch..."
    Write-Progress -Activity "GPO Migration" -Status "Uploading PS1 Script to AirWatch" -PercentComplete 40
    $uploadScriptResponse = Upload-Blob -filename $confirmPackageScriptFilename -filepath $confirmPackageScriptFilepath
    if ($uploadScriptResponse -eq $null -or $uploadScriptResponse.uuid -eq $null) {
        Write-Progress -Activity "GPO Migration" -Completed
        return Write-Host "An error occurred when attempting to upload the .ps1 script to AirWatch - quitting! Check the output for more details."
    }

    # Build app properties
    Write-Progress -Activity "GPO Migration" -Status "Building App Properties" -PercentComplete 50
    [hashtable] $appProperties = @{}
    $appProperties.Add("ApplicationName", $gpoPackage.filename)
    $appProperties.Add("BlobId", $uploadBlobResponse.Value)
    $appProperties.Add("CustomScriptFileBlodId", $uploadScriptResponse.Value)
    $appPropertiesJSON = Map-AppDetailsJSON -appProperties $appProperties

    # Publish App to AirWatch
    Write-Host "Saving GPO package app to AirWatch Console..."
    Write-Progress -Activity "GPO Migration" -Status "Installing GPO Package in AirWatch" -PercentComplete 75
    $saveAppResponse = Save-App -appProperties $appPropertiesJSON
    if ($saveAppResponse -eq $null -or $saveAppResponse.uuid -eq $null) {
        Write-Progress -Activity "GPO Migration" -Completed
        return Write-Host "An error occurred when attempting to save the GPO package app to the AirWatch Console - quitting! Check the output for more details."
    }
    else {
        Write-Host "Successfully saved GPO package app to the AirWatch Console!"
        Write-Host "`n----- IMPORTANT -----"
        Write-Host "Be sure to navigate to the AirWatch Console and assign the `napplication '$($gpoPackage.filename)' to the appropriate users and devices!"
        Write-Host "----- IMPORTANT -----"
    }

    Write-Progress -Activity "GPO Migration" -Status "Finished Uploading GPO Package" -PercentComplete 100
    Write-Progress -Activity "GPO Migration" -Completed
}

<#
    Calls the /api/mam/blobs/uploadblob endpoint to upload a blob to the AirWatch Console
#>
function Upload-Blob {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$filename,
        [Parameter(Mandatory=$True)]
        [string]$filepath
	)
    
    $headers = Build-AirWatchHeaders -contentType "application/octet-stream"
    $endpoint = "$awServer/api/mam/blobs/uploadblob?filename=$filename&organizationgroupid=$awGroupID"

    Write-Verbose "------  mam/blobs/uploadblob API ------"
    Write-Verbose "headers: $headers"
    Write-Verbose "endpoint: $endpoint"
    Write-Verbose "InFile filepath: $filepath"
    Write-Verbose "---------------------------------------`n"

    try {
	    $response = Invoke-RestMethod -Method Post -Uri $endpoint.ToString() -Headers $headers -InFile $filepath
    } 
    catch [System.Net.WebException] {
        $response = $_.Exception.Response | ConvertTo-Json
        Write-Error "Uploading Blob to AirWatch ($endpoint) Failed! Exception :: $($_.Exception.Message)"
        Write-Error "RESPONSE :: $($_.Exception.Response | ConvertTo-Json)"
    } 
    catch {
        $response = $null
        Write-Error "Saving GPO Package to AirWatch ($endpoint) encountered an unexpected error! Exception :: $($_.Exception.Message)"
    }

    Write-Verbose "mam/blobs/uploadblob response :: $($response | ConvertTo-Json)"
    return $response
}

<#
    Calls the /api/mam/apps/internal/begininstall endpoint to publish an uploaded application to the AirWatch Console
#>
function Save-App {
    Param(
        [Parameter(Mandatory=$True)]
        $appProperties
	)

    $headers = Build-AirWatchHeaders
    $endpoint = "$awServer/api/mam/apps/internal/begininstall"

    Write-Verbose "------  mam/apps/internal/begininstall API ------"
    Write-Verbose "headers: $headers"
    Write-Verbose "endpoint: $endpoint"
    Write-Verbose "JSON body: $appProperties"
    Write-Verbose "-------------------------------------------------`n"

    try {
	    $response = Invoke-RestMethod -Method Post -Uri $endpoint.ToString() -Headers $headers -Body $appProperties
    }
    catch [System.Net.WebException] {
        $response = $_.Exception.Response | ConvertTo-Json
        Write-Error "Saving GPO Package to AirWatch ($endpoint) Failed! Exception :: $($_.Exception.Message)"
        Write-Error "RESPONSE :: $($_.Exception.Response | ConvertTo-Json)"
    } 
    catch {
        $response = $null
        Write-Error "Saving GPO Package to AirWatch ($endpoint) encountered an unexpected error! Exception :: $($_.Exception.Message)"
    }

    Write-Verbose "mam/apps/internal/begininstall response :: $($response | ConvertTo-Json)"
    return $response
}

<#
    Creates the JSON body for the Save-App method to specify the required properties of the uploaded application
#>
function Map-AppDetailsJSON {
    Param(
		[Parameter(Mandatory=$True)]
		[hashtable] $appProperties
	)

    # Get AirWatch Version and parse into double 
    $awVersionStr = Get-AirWatchVersion
    $awVersionArr = $awVersionStr.Split('.')
    $awVersion = [Double]($awVersionArr[0] + "." + $awVersionArr[1])

    # Setup properties reliant on AW versions
    if ($awVersion -ge 9.2) {
        $appProperties.Add("DeviceType", 12)
        $appProperties.Add("SupportedModels", @{
            Model = @(@{
                ModelId = 83
                ModelName = "Desktop"
            })
        })
    }
    else {
        $appProperties.Add("DeviceType", 12)
        $appProperties.Add("SupportedModels", @{
            Model = @(@{
                ModelId = 50
                ModelName = "Windows 10"
            })
        })
    }
    
    # Build App Details body
    $body = @{
	    ApplicationName = $appProperties.ApplicationName
	    BlobId = $appProperties.BlobId
	    DeviceType = $appProperties.DeviceType
	    SupportedModels = $appProperties.SupportedModels
	    PushMode = 0
	    SupportedProcessorArchitecture = "x64"
	    EnableProvisioning = "true"
	    IsDependencyFile = "false"
	    LocationGroupId = $awGroupID
	    DeploymentOptions = @{
            WhenToInstall = @{
                DiskSpaceRequiredInKb = 1000
                DevicePowerRequired = 0
                RamRequiredInMb = 1
            }
            HowToInstall = @{
                InstallContext = "Device"
                InstallCommand = "powershell -executionpolicy bypass -File DeployPackage.ps1"
                AdminPrivileges = "true"
                DeviceRestart = "DoNotRestart"
                RetryCount = 3
                RetryIntervalInMinutes = 5
                InstallTimeoutInMinutes = 30
                InstallerRebootExitCode = "0"
                InstallerSuccessExitCode = "0"
            }
            WhenToCallInstallComplete = @{
                IdentifyApplicationBy = "UsingCustomScript"
                CustomScript = @{
                    ScriptType = "PowerShell"
                    CommandToRunTheScript = "powershell -executionpolicy bypass -File LGPOConfirmPackageInstall.ps1"
                    CustomScriptFileBlodId = $appProperties.CustomScriptFileBlodId
                    SuccessExitCode = 0
                }
            }
        }
        FilesOptions = @{
            ApplicationUnInstallProcess = @{
                UseCustomScript = "true"
                CustomScript = @{
                    CustomScriptType = "Input"
                    UninstallCommand = "LGPO.exe"
                }
            }
        }
    }
    $json = $body | ConvertTo-Json -Depth 10
    return $json
}

<#
    Calls the /api/system/info endpoint to retrieve the version of the target AirWatch server
#>
function Get-AirWatchVersion {
    $headers = Build-AirWatchHeaders

    try {
        $endpoint = "$awServer/api/system/info"
	    $response = Invoke-RestMethod -Method Get -Uri $endpoint.ToString() -Headers $headers
        $version = $response.ProductVersion

    }
    catch [System.Net.WebException] {
        $response = $_.Exception.Response | ConvertTo-Json
        Write-Error "Querying AirWatch version ($endpoint) Failed! Exception :: $($_.Exception.Message)"
        Write-Error "RESPONSE :: $($_.Exception.Response | ConvertTo-Json)"
    } 
    catch {
        $response = $null
        Write-Error "Get AirWatch Version failed :: $PSItem"
    }

    Write-Verbose "Get AirWatch Version response :: $response"
    return $version;
}

<#
    Calls the /api/v1/system/groups/{groupId} endpoint query the details of an orgainzation group
#>
function Get-AirWatchOrganizationGroup {
    Param(
        [Parameter(Mandatory=$True)]
        [int]$orgGroupId
	)

    $headers = Build-AirWatchHeaders

    try {
        $endpoint = "$awServer/api/v1/system/groups/$orgGroupId"
        $response = Invoke-RestMethod -Method Get -Uri $endpoint.ToString() -Headers $headers
    }
    catch [System.Net.WebException] {
        $response = $_.Exception.Response | ConvertTo-Json
        Write-Error "Querying AirWatch organization group ID ($endpoint) Failed! Exception :: $($_.Exception.Message)"
        Write-Error "RESPONSE :: $($_.Exception.Response | ConvertTo-Json)"
    } 
    catch {
        $response = $null
        Write-Error "Get AirWatch Organization Group failed :: $PSItem"
    }

    Write-Verbose "Get AirWatch Organization Group response :: $response"
    return $response
}
#endregion

#region API Helpers
<#
    Test that the AirWatch API authentication is successful and able to manage the Org GroupID provided
#>
function Confirm-AirWatchAPIAuthentication {
    $authenticated = $true
    $awApiResponse = $null

    # Query if authenticated API user can query the details of the provided Org GroupID
    try {
        $response = Get-AirWatchOrganizationGroup -orgGroupId $awGroupID
        # Query response should contain the 'name' property. If it is empty, save the response to display to the user
        if ([string]::IsNullOrEmpty($response.Name)) {
            $awApiResponse = $response
        }
    }
    catch {
        $awApiResponse = $PSItem
    }

    # If an issue was detected, report it to the user and display their input for the AirWatch API details
    if ($awApiResponse -ne $null) {
        Write-Warning "Unable to connect to the AirWatch API and validate the Organization Group ID '$awGroupID'!  Error Response:: $awApiResponse"
        Write-Warning "Check the values you entered for the AirWatch Environment and sure they are correct!"
        Write-Warning "AirWatch Server URL: '$awServer'"
        Write-Warning "AirWatch API Key: '$awTenantAPIKey'"
        Write-Warning "AirWatch API User Username: '$awUsername'"
        Write-Warning "AirWatch API User Password: '$awPassword'"
        Write-Warning "AirWatch Organization Group ID: '$awGroupID'"
        
        $authenticated = $false
    }

    $Script:apiAuthenticated = $authenticated 
    return $authenticated
}

<#
    Checks if the parameters for authenticating against the APIs has been entered and prompts for
    input if details are missing.  Also allows user to re-enter credentials if needed.
#>
function Confirm-AirWatchAPIDetails {
    Param (
        [Parameter(Mandatory=$False)]
        [bool]$override = $False
    )

    $inputRequired = ($override -or $(Check-AirWatchAPIDetailsExist) -eq $false)

    # if we are overriding the API details, or if any of the details are missing, notify the user why they are about to be prompted to enter these details
    if ($inputRequired) {
        Write-Host "`nIMPORTANT: Enter the following prompts to authenticate against the AirWatch API for the next tasks!"
    
        # Update our variables with the input
        if ([string]::IsNullOrEmpty($awServer) -or $override) { $Script:awServer = Read-Host -Prompt "awServer" }
        if ([string]::IsNullOrEmpty($awUsername) -or $override) { $Script:awUsername = Read-Host -Prompt "awUsername" }
        if ([string]::IsNullOrEmpty($awPassword) -or $override) { $Script:awPassword = Read-Host -Prompt "awPassword" }
        if ([string]::IsNullOrEmpty($awTenantAPIKey) -or $override) { $Script:awTenantAPIKey = Read-Host -Prompt "awTenantAPIKey" }
        if ([string]::IsNullOrEmpty($awGroupID) -or $override) { $Script:awGroupID = Read-Host -Prompt "awGroupID" }

        # Attempt API authentication and report result
        Write-Host "`nConfirming AirWatch API authentication... this may take a few moments"
        $authenticated = Confirm-AirWatchAPIAuthentication
        return $authenticated
    }
    else {
        # If input already exists and we are not overriding, return true to continue
        return $true
    }
}

<#
    Checks if any of the required API Details are missing
#>
function Check-AirWatchAPIDetailsExist {
    return (![string]::IsNullOrEmpty($awServer) -and 
            ![string]::IsNullOrEmpty($awUsername) -and 
            ![string]::IsNullOrEmpty($awPassword) -and 
            ![string]::IsNullOrEmpty($awTenantAPIKey) -and 
            ![string]::IsNullOrEmpty($awGroupID))
}

<#
    Builds the necessary headers for an AirWatch API request including authorization
#>
function Build-AirWatchHeaders {
    Param (
        [Parameter(Mandatory=$False)]
        [string]$acceptType = "application/json",
        [Parameter(Mandatory=$False)]
        [string]$contentType = "application/json"
    )
    $authoriztionString = Get-BasicUserForAuth
    $header = @{ "Authorization" = $authoriztionString; "aw-tenant-code" = $awTenantAPIKey; "Accept" = $acceptType; "Content-Type" = $contentType }
    return $header
}

<#
    Base64 Encoding for the AirWatch account credentials to authorize the API request
#>
Function Get-BasicUserForAuth {
	$basicAuthString = $awUsername + ":" + $awPassword
	$encoding = [System.Text.Encoding]::ASCII.GetBytes($basicAuthString)
	$encodedString = [Convert]::ToBase64String($encoding)
	
	Return "Basic " + $encodedString
}
#endregion

#region PS Helpers
<#
    Builds the DeployPackage.csv file included in the uploaded GPO .zip package, which is used
    by the assigned devices to know which GPO policies to import and in which order
#>
function Build-DeployPackageCSV {
    Param (
        [Parameter(Mandatory=$True)]
        [System.Collections.Generic.List[System.Object]]$GPOs
    )

    $filepath = "$PSScriptRoot\DeployPackage.csv"
    $GPOs | Export-Csv -Path $filepath

    Write-Verbose "Build-DeployPackageCSV filepath = $filepath"
    return $filepath
}
#endregion

#region MAIN
<#
    Ensure that the necessary folders, paths, and executables exist for the script to work properly.
    Ensure that the provided AirWatch API endpoint and group ID can be reached and managed with the AirWatch user credentials.
#>
function Initialize {
    $pass = $true
    
    # Ensure backup folder exists, create if needed
    if (!(Test-Path -Path $backupFolder)) { 
        New-Item -Path $backupFolder -ItemType Directory 
    }

    # Ensure upload folder exists, create if needed
    if (!(Test-Path -Path $uploadFolder)) {
        New-Item -Path $uploadFolder -ItemType Directory
    }

    # Ensure LGPO.exe exists, instruct to download and place file in project if missing
    if (!(Test-Path -Path $lgpoPath)) { 
        Write-Warning "LGPO.exe does not exist within '$basePath'!"
        Write-Warning "To use this tool, download the Microsoft Security Compliance Toolkit (https://www.microsoft.com/en-us/download/details.aspx?id=55319)`nand place the LGPO.exe file within the directory '$basePath' and then run this script again!" 
        $pass = $false
    }

    # Ensure AW APIs are reachable and authenticate successfully, reporting failure for any issues
    if ($(Check-AirWatchAPIDetailsExist) -eq $true) {
        $authenticated = Confirm-AirWatchAPIAuthentication
        if ($authenticated -eq $false) {
            $pass = $false
        }
    }

    return $pass
}

function MAIN {
    # Run initialization checks
    if (!$initialized) {
        Write-Host "Initializing... This may take a few moments!"
        
        $initialized = Initialize
        if (!$initialized) { 
            Write-Host "Initialization Failed!  Check the output for details!"
            return 
        }
        
        Write-Host "Initialization checks completed"
    }

    # Prompt for Task input and handle selection
    Write-Host "`nChoose a Task:"
    Write-Host "============="
    Write-Host "(1) List GPO Backups"
    Write-Host "(2) Capture Local GPO Backup"
    Write-Host "(3) Upload GPO to AirWatch"
    Write-Host "(0) END"
    $selection = Read-Host -Prompt "Selection"

    # Handle Task selection
    switch ($selection) {
        "1" {
            Get-GPOBackups | Out-GridView -OutputMode Multiple -Title "GPO Backups"
        }

        "2" {
            $capturedGPO = Capture-LocalGPO
            if ($capturedGPO.success -eq $false) {
                Write-Host "`nCapture-LocalGPO: Failed to capture local GPO!"
            }
            else {
                Write-Host "`nCapture-LocalGPO: Successfully captured local GPO and assigned it the name '$($capturedGPO.name)'!"
            }
        }

        "3" {
            $authenticated = Confirm-AirWatchAPIDetails -override $(-Not $apiAuthenticated)
            if ($authenticated -eq $true) {
                Write-Host "AirWatch API authentication succeeded - continuing!"
                Upload-GPOsToAirWatch
            }
            else {
                Write-Host "AirWatch API authentication failed - quitting! Check the output for additional details."
            }
        }

        "0" { }

        default {
            Write-Host "Invalid choice! Please choose a value from the above list."
        }
    }

    if ($selection -ne "0") {
        MAIN
    }
}

# Call MAIN to start
MAIN 