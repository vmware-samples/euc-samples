[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$awServer,

    [Parameter(Mandatory=$True)]
    [string]$awTenantAPIKey,

    [Parameter(Mandatory=$True)]
    [string]$awUsername,

    [Parameter(Mandatory=$True)]
    [string]$awPassword,

    [Parameter(Mandatory=$True)]
    [string]$awGroupID
)

Write-Verbose "---- Command Line Parameters ----"
Write-Verbose "awServer: '$awServer'"
Write-Verbose "awTenantAPIKey: '$awTenantAPIKey'"
Write-Verbose "awUsername: '$awUsername'"
Write-Verbose "awPassword: '$awPassword'"
Write-Verbose "awGroupID: '$awGroupID'"
Write-Verbose "---------------------------------`n"

# State Vars
$global:isVerbose = $false
$initialized = $false
$apiAuthenticated = $false


$download_path = "C:\Temp\Downloads"
$lgpo_path = "$download_path\LGPO.zip"
$log_path = "C:\Temp\Logs"
$scriptfilename = "$env:computername-downloadLGPO.log" #local log file name



function Initialize{
    If ((Test-Path $download_path) -eq $false){
        md $download_path
    }
    If ((Test-Path $log_path) -eq $false){
        md $log_path
    }
}


#region MSFT Download & Repackaging
<#
    Downloads the LGPO.exe in a zip file, and 
    extracts the .exe
#>
function Download-LGPO{
    $url = "https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip"    
    $start_time = Get-Date

    If((Test-Path $lgpo_path) -eq $false){
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($url, $lgpo_path)

        Write-Output "`nTime taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
    }
    else{
        Write-Output "`nFile already exists. Extracting..."        
    }

    Expand-Archive -LiteralPath $lgpo_path -DestinationPath $download_path -Force

}


<#
    Repackages LGPO.exe with Deploy-LGPO.ps1 which
    is run on endpoints to extract LGPO.exe into 
    the appropriate folder
#>
function Build-Package{
    
    if ((Test-Path ./Deploy-LGPO.ps1) -eq $false){
        Write-Host "`nDeploy-LGPO.ps1 was not found. Please download the script from the source."
        gotoescape
    }
    else {
        if ((Test-Path $download_path/LGPO-Package.zip) -eq $false) {
            Write-Output "`nBuilding LGPO-Package.zip..."        
            Compress-Archive -LiteralPath $download_path/LGPO.exe, ./Deploy-LGPO.ps1 -CompressionLevel Optimal -DestinationPath $download_path/LGPO-Package.zip
            return
        }
        else{
            return Write-Output "`nLGPO-Package.zip already exists. Moving on to Upload..."
        }
    }    

}

    
<#
    Exit the script in case of errors
#>
function gotoescape{
    Write-Host "Exiting..."
    Stop-Transcript
    Exit
}


function Main{    
    # If passed the verbose arg, set the global var
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
      $global:isVerbose = $true
    }

    Start-Transcript $log_path\$scriptfilename    

    $authString = Get-BasicUserForAuth -username $awUsername -password $awPassword    
    $headers = Build-AirWatchHeaders -acceptType "application/json"
    $str = $headers | Out-String
    Write-Verbose "Headers :: $($str)"

    $version = Get-AirWatchVersion -headers $headers
    Write-Host "`nAirWatch Version is $($version)"

    Initialize    
    Download-LGPO    
    Build-Package
    Upload-LGPOtoAirWatch
        
    Stop-Transcript
}



#region AirWatch APIs
<#
    Uploads the .zip package as blob to
    the UEMConsole, then publishes the application.
#>
function Upload-LGPOtoAirWatch{
    [hashtable] $appProperties = @{}

    # Setup properties depending on AW version
    $awVersion = [System.Version]$(Get-AirWatchVersion)
    if ($awVersion -le [System.Version]"9.2.3.0") {
        $identifyApplicationByCriteria = "DefiningCriteria"
    }
    $appProperties.Add("IdentifyApplicationByCriteria", $identifyApplicationByCriteria)
    
    Write-Host "`nBeginning UploadLGPOToAirWatch."    
    Write-Progress -Activity "LGPO Upload" -Status "Building LGPO Package" -PercentComplete 10
    
    # Upload zip Blob to AW
    Write-Host "Uploading .zip package to AirWatch..."    
    $uploadBlobResponse = Upload-Blob -filename "LGPO-Package.zip" -filepath "$download_path/LGPO-Package.zip" -isSFDApp $true
    if ($uploadBlobResponse -eq $null -or $uploadBlobResponse.uuid -eq $null) {
        Write-Progress -Activity "LGPO-Package.zip Upload" -Completed
        return Write-Host "An error occurred when attempting to upload the .zip file to AirWatch - quitting! Check the output for more details."
    }

    # Build app properties
    Write-Progress -Activity "Creating App Record" -Status "Building App information..." -PercentComplete 50
    $appProperties.Add("ApplicationName", "LGPO-Package.zip")
    $appProperties.Add("BlobId", $uploadBlobResponse.Value)
    $appPropertiesJSON = Map-AppDetailsJSON -appProperties $appProperties

    # Publish App to AirWatch
    Write-Host "Saving App package to UEM Console..."
    Write-Progress -Activity "Creating App Record" -Status "Installing App Package in UEM Console..." -PercentComplete 75
    $saveAppResponse = Save-App -appProperties $appPropertiesJSON
    if ($saveAppResponse -eq $null -or $saveAppResponse.uuid -eq $null) {
        Write-Progress -Activity "Creating App Record" -Completed
        return Write-Host "An error occurred when attempting to save the GPO package app to the AirWatch Console - quitting! Check the output for more details."
    }
    else {
        Write-Host "Successfully saved LGPO-Package app to the UEM Console!"
        Write-Host "`n----- IMPORTANT -----"
        Write-Host "Be sure to navigate to the UEM Console and assign the `napplication 'LGPO-Package.zip' to the appropriate users and devices!"
        Write-Host "----- IMPORTANT -----"
    }
}


<#
    Calls the /api/mam/blobs/uploadblob endpoint to upload a blob to the AirWatch Console
#>
function Upload-Blob {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$filename,
        [Parameter(Mandatory=$True)]
        [string]$filepath,
        [Parameter(Mandatory=$False)]
        [bool]$isSFDApp = $False
    )
    
    $headers = Build-AirWatchHeaders -contentType "application/octet-stream"
    $endpoint = "$awServer/api/mam/blobs/uploadblob?filename=$filename&organizationgroupid=$awGroupID"
    if ($isSFDApp -eq $true) {
        $endpoint = "$($endpoint)&moduleType=Application"
    }

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
        Write-Error "Uploading Blob to UEM Console: ($endpoint) Failed! Exception :: $($_.Exception.Message)"
        Write-Error "RESPONSE :: $($_.Exception.Response | ConvertTo-Json)"
    } 
    catch {
        $response = $null
        Write-Error "Uploading LGPO-Package files to UEM Console: ($endpoint) encountered an unexpected error! Exception :: $($_.Exception.Message)"
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
        Write-Error "Saving LGPO-Package to UEM Console: ($endpoint) Failed! Exception :: $($_.Exception.Message)"
        Write-Error "RESPONSE :: $($_.Exception.Response | ConvertTo-Json)"
    } 
    catch {
        $response = $null
        Write-Error "Saving LGPO-Package to UEM Console: ($endpoint) encountered an unexpected error! Exception :: $($_.Exception.Message)"
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

    # Get AirWatch Version and parse
    $awVersion = [System.Version]$(Get-AirWatchVersion)

    # Setup properties reliant on AW versions
    if ($awVersion -ge [System.Version]"9.2.0.0") {
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
        SupportedProcessorArchitecture = "x86"
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
                InstallCommand = "powershell -executionpolicy bypass -File ./Deploy-LGPO.ps1"
                AdminPrivileges = "true"
                DeviceRestart = "DoNotRestart"
                RetryCount = "3"
                RetryIntervalInMinutes = "5"
                InstallTimeoutInMinutes = "10"
                InstallerRebootExitCode = "0"
                InstallerSuccessExitCode = "0"
            }
            WhenToCallInstallComplete = @{
                UseAdditionalCriteria = "false"
                IdentifyApplicationBy = "DefiningCriteria"
                CriteriaList = @(@{   
                    CriteriaType = "FileExists"
                    FileCriteria = @{
                        Path = "$env:ProgramData\AirWatch\LGPO\LGPO.exe"
                        VersionCondition = "Any"
                        MajorVersion = 0
                        MinorVersion = 0
                        RevisionNumber = 0
                        BuildNumber = 0
                        ModifiedOn = "01/01/2017"
                    }
                    LogicalCondition = "End"
                })
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
        Write-Error "Get WS1 UEM Organization Group failed :: $PSItem"
    }

    Write-Verbose "Get WS1 UEM Organization Group response :: $response"
    return $response
}



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
        [Parameter(Mandatory=$False)]`
        [string]$contentType = "application/json"
    )
    $authorizationString = Get-BasicUserForAuth
    $header = @{ "Authorization" = $authorizationString; "aw-tenant-code" = $awTenantAPIKey; "Accept" = $acceptType; "Content-Type" = $contentType }
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

Function Invoke-AirWatchAPIRequest {

    [CmdletBinding()]
    Param(
        # Headers for API Call
        [Parameter(Mandatory=$True)]
        [hashtable]
        $headers,

        # REST API Verb (GET, PATCH)
        [Parameter(Mandatory=$True)]
        [string]
        $Verb,

        [Parameter(Mandatory=$True)]
        [string]
        $awURL
    )

    # If we are in verbose mode
    if ($global:isVerbose) {
        $response = Invoke-RestMethod -Method $Verb -Uri $awURL -Headers $headers -Verbose
    }
    else {
        $response = Invoke-RestMethod -Method $Verb -Uri $awURL -Headers $headers
    }

    Return $response
}
#end-region

Main