<# Workspace ONE Script Importer

# Author:  Josue Negron - jnegron@vmware.com
# Created: Jan 2021
# Updated: Jan 2021
# Version 1.0

  .SYNOPSIS
    This Powershell script allows you to automatically import Windows 10 and macOS scripts as Workspace ONE Scripts in the Workspace ONE UEM Console. 
    MUST RUN AS ADMIN

  .DESCRIPTION
    Place this PowerShell script in the same directory of all of your samples (.ps1, .sh, .zsh, .py files) or use the -ScriptsDirectory parameter to 
    specify your directory. This script when run will parse the sample scripts, check if they already exist, then upload to Workspace ONE UEM via 
    the REST API. You can leverage the optional switch parameters to update scripts or delete all scripts. 

  .EXAMPLE

    .\import_script_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin 'administrator' `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone' `
        -SmartGroupName 'All Devices' `
        -UpdateScripts `
        -TriggerType 'SCHEDULE_AND_EVENT' `
        -SCHEDULE 'FOUR_HOURS' `
        -LOGIN -LOGOUT

    .SCRIPT HEADER TEMPLATE
        # Description
        # Execution Context: System | User
        # Execution Architecture: EITHER_64BIT_OR_32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY (for macOS leave blank or use 'UNKNOWN')
        # Timeout: ## greater than 0
        # Variables: KEY,VALUE; KEY,VALUE

    .PARAMETER WorkspaceONEServer
    Server URL for the Workspace ONE UEM API Server

    .PARAMETER WorkspaceONEAdmin
    An Workspace ONE UEM admin account in the tenant that is being queried.  This admin must have the API role at a minimum.

    .PARAMETER WorkspaceONEAdminPW
    The password that is used by the admin specified in the username parameter

    .PARAMETER WorkspaceONEAPIKey
    This is the REST API key that is generated in the Workspace ONE UEM Console.  You locate this key at All Settings -> Advanced -> API -> REST,
    and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access

    .PARAMETER OrganizationGroupName
    OPTIONAL: The display name of the Organization Group. You can find this at the top of the console, normally your company's name.
    Required to provide OrganizationGroupName or OrganizationGroupID.

    .PARAMETER OrganizationGroupID
    OPTIONAL: The Group ID for your organization group. You can find this at the top of the console by hovering over the company name.
    Required to provide OrganizationGroupName or OrganizationGroupID.

    .PARAMETER ScriptsDirectory
    OPTIONAL: The directory your script samples are located, default location is the current PowerShell directory of this script. 

    .PARAMETER SmartGroupID
    OPTIONAL: If provided, all scripts in your environment will be assigned to this Smart Group. Exisiting assignments will be overwritten. 
    If wanting to assigned, you are required to provide SmartGroupID or SmartGroupName.

    .PARAMETER SmartGroupID
    OPTIONAL: If provided, all scripts in your environment will be assigned to this Smart Group. Exisiting assignments will be overwritten. 
    If wanting to assigned, you are required to provide SmartGroupID or SmartGroupName.
    
    .PARAMETER DeleteScripts
    OPTIONAL: If enabled, all sensors in your environment will be deleted. This action cannot be undone. Ensure you are targeting the correct Organization Group. 
    
    .PARAMETER UpdateScripts
    OPTIONAL: If enabled, all scripts that match will be updated with the version in the PowerShell samples. 

    .PARAMETER ExportScripts
    OPTIONAL: If enabled, all scripts will be downloaded locally, this is a good option for backuping up scripts before making updates. 

    .PARAMETER Platform
    OPTIONAL: Keep disabled to import all platforms. If enabled, determines what platform's sensors to import. Supported values are "Windows" or "macOS".  
    
    .PARAMETER TriggerType
    OPTIONAL: When bulk assigning, provide the Trigger Type: 'SCHEDULE', 'EVENT', or 'SCHEDULE_AND_EVENT'

    .PARAMETER SCHEDULE
    OPTIONAL: When using 'SCHEDULE' or 'SCHEDULE_AND_EVENT' as TriggerType provide the schedule interval: 'FOUR_HOURS', 'SIX_HOURS', 'EIGHT_HOURS', 'TWELEVE_HOURS', or 'TWENTY_FOUR_HOURS'

    .PARAMETER LOGIN
    OPTIONAL: When using 'EVENT' or 'SCHEDULE_AND_EVENT' as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'

    .PARAMETER LOGOUT
    OPTIONAL: When using 'EVENT' or 'SCHEDULE_AND_EVENT' as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'
    
    .PARAMETER STARTUP
    OPTIONAL: When using 'EVENT' or 'SCHEDULE_AND_EVENT' as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'
    
    .PARAMETER RUN_IMMEDIATELY
    OPTIONAL: When using 'EVENT' or 'SCHEDULE_AND_EVENT' as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'

    .PARAMETER NETWORK_CHANGE
    OPTIONAL: When using 'EVENT' or 'SCHEDULE_AND_EVENT' as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'
#>

[CmdletBinding()]
    Param(

        [Parameter(Mandatory=$True)]
        [string]$WorkspaceONEServer,

        [Parameter(Mandatory=$True)]
        [string]$WorkspaceONEAdmin,

        [Parameter(Mandatory=$True)]
        [string]$WorkspaceONEAdminPW,

        [Parameter(Mandatory=$True)]
        [string]$WorkspaceONEAPIKey,

        [Parameter(Mandatory=$False)]
        [string]$OrganizationGroupName, 

        [Parameter(Mandatory=$False)]
        [string]$OrganizationGroupID, 

        [Parameter(Mandatory=$False)]
        [string]$ScriptsDirectory, 

        [Parameter(Mandatory=$False)]
        [int]$SmartGroupID, 

        [Parameter(Mandatory=$False)]
        [string]$SmartGroupName, 

        [Parameter(Mandatory=$False)]
        [switch]$UpdateScripts, 

        [Parameter(Mandatory=$False)]
        [switch]$DeleteScripts,

        [Parameter(Mandatory=$False)]
        [switch]$ExportScripts,

        [Parameter(Mandatory=$False)]
        [string]$TriggerType, 

        [Parameter(Mandatory=$False)]
        [string]$Platform, 

        [Parameter(Mandatory=$False)]
        [switch]$LOGIN,

        [Parameter(Mandatory=$False)]
        [switch]$LOGOUT,

        [Parameter(Mandatory=$False)]
        [switch]$STARTUP,

        [Parameter(Mandatory=$False)]
        [switch]$RUN_IMMEDIATELY,

        [Parameter(Mandatory=$False)]
        [switch]$NETWORK_CHANGE,

        [Parameter(Mandatory=$False)]
        [string]$SCHEDULE
)

# Forces the use of TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$URL = $WorkspaceONEServer + "/API"
$global:CurrentScriptUUID = ""

# If a custom script directory is not provided then use current directory of import_script_samples.ps1 
if (!$ScriptsDirectory) {$ScriptsDirectory = Get-Location}

# Base64 Encode Workspace ONE UEM Username and Password for API Access
$combined = $WorkspaceONEAdmin + ":" + $WorkspaceONEAdminPW
$encoding = [System.Text.Encoding]::ASCII.GetBytes($combined)
$cred = [Convert]::ToBase64String($encoding)

# Returns the Numerial Organization ID for the Organizational Group Name Provided
Function Get-OrganizationIDbyName {
    Write-Host("Getting Organization ID from Group Name")
    $endpointURL = $URL + "/system/groups/search?name=" + $OrganizationGroupName
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $totalReturned = $webReturn.Total
    $ogID = -1
    If ($webReturn.Total = 1) {
        $ogID = $webReturn.LocationGroups.Id.Value
        Write-Host("Organization ID for " + $OrganizationGroupName + " = " + $ogID)
    } else {
        Write-host("Group Name: " + $OrganizationGroupName + " not found")
    }
    Return $ogID
}

# Returns the Numerial Organization ID for the Organizational Group ID Provided
Function Get-OrganizationIDbyID {
    Write-Host("Getting Organization ID from Group ID")
    $endpointURL = $URL + "/system/groups/search?groupID=" + $OrganizationGroupID
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $totalReturned = $webReturn.Total
    $ogID = -1
    If ($webReturn.Total = 1) {
        $ogID = $webReturn.LocationGroups.Id.Value
        Write-Host("Organization ID for " + $OrganizationGroupID + " = " + $ogID)
    } else {
        Write-host("Group ID: " + $OrganizationGroupID + " not found")
    }
    Return $ogID
}

# Returns the UUID of the Organization ID Provided
Function Get-OrganizationGroupUUID($ogID) {
    Write-Host("Getting Group UUID from Group Name")
    $endpointURL = $URL + "/system/groups/" + $ogID
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $groupUUID = $webReturn.Uuid
    Return $groupUUID
}

# Returns the UUID of the Smart Group Provided
Function Get-SmartGroupUUIDbyID($SmartGroupID) {
    Write-Host("Getting Group UUID from Group Name")
    $endpointURL = $URL + "/mdm/smartgroups/" + $SmartGroupID.ToString()
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $SmartGroupUUID = $webReturn.SmartGroupUuid
    Return $SmartGroupUUID
}

# Returns the Name of the Smart Group ID Provided
Function Get-SmartGroupName($SmartGroupID) {
    $endpointURL = $URL + "/mdm/smartgroups/" + $SmartGroupID.ToString()
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $SmartGroupName = $webReturn.Name
    Return $SmartGroupName
}

# Returns the UUID of the Smart Group Name Provided
Function Get-SmartGroupUUIDbyName($SmartGroupName, $OgID) {
    $endpointURL = $URL + "/mdm/smartgroups/search?name=" + $SmartGroupName + "&managedbyorganizationgroupid=" + $OgID
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $SmartGroupUUID = $webReturn.SmartGroups.SmartGroupUuid
    Return $SmartGroupUUID
}

# Returns Workspace ONE UEM Console Version
Function Check-ConsoleVersion {
    Write-Host("Checking Console Version")
    $endpointURL = $URL + "/system/info"
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $ProductVersion = $webReturn.ProductVersion
    $Version = $ProductVersion -replace '[\.]'
    $Version = [int]$Version
    if ($Version -ge 20100) {
        Write-Host("Console Version " + $ProductVersion)
        Return $null
    }else{
        Write-Host("Your Console Version is " + $ProductVersion + " scripts only works on Console Version 2010 or above.") -ForegroundColor Yellow 
        $Response = Read-Host "Would you like to continue anyways? Only continue if you are sure you are running 2010+ ( y / n )" 
    Switch ($Response) 
     { 
       Y {Write-host "Yes, Continuing Anyways"; Return $null} 
       N {Write-Host "Exiting Script"; Exit} 
       Default {Write-Host "Exiting Script"; Exit} 
     } 
    }
}

# Returns a list of Scripts from Workspace ONE UEM Console
Function Get-Scripts {
    Write-Host("Getting List of Scripts")
    $endpointURL = $URL + "/mdm/groups/" + $WorkspaceONEGroupUUID + "/scripts?page_size=1000"
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $Scripts = $webReturn
    if($Scripts){
        Write-Host($Scripts.RecordCount.toString() + " Scripts Found in Console")
    }ELSE{
        Write-Host("No Scripts Found in Console")}
    Return $Scripts
}

# Creates a new Script to the Workspace ONE UEM Console
Function Set-Scripts($Description, $Context, $ScriptName, $Timeout, $Script, $Script_Type, $OS, $Architecture, $Varibles) {
    Write-Host("Creating new Script with name " + $ScriptName)
    $endpointURL = $URL + "/mdm/groups/" + $WorkspaceONEGroupUUID + "/scripts"
    if($Varibles){
        $KeyValuePair = $Varibles.Split(";")
        $VaribleBody = @()
        foreach ($i in $KeyValuePair){
            $Key = $i.Split(",")[0]
            $Value = $i.Split(",")[1]
            $VaribleBody += @{
                'name'  = $Key;
                'value' = $Value;
            }
        }
    }
    if(!$Architecture){$Architecture="UNKNOWN"}
    $body = @{
        'name'	                  = "$ScriptName";
        'description'             = "$Description";
        'platform'	              = "$OS";
        'script_type'	          = "$Script_Type";
        'platform_architecture'   = "$Architecture";
        'execution_context'	      = "$Context";
        'script_data'	          = "$Script";
        'timeout'	              = "$Timeout";
        'script_variables'        = $VaribleBody;
        'allowed_in_catalog'      = "$False";
            }
    $json = $body | ConvertTo-Json -Depth 20
    $webReturn = Invoke-RestMethod -Method Post -Uri $endpointURL -Headers $header -Body $json
    $Status = $webReturn
    Return $Status
}

# Updates Exisiting Scripts in the Workspace ONE UEM Console
Function Update-Scripts($Description, $Context, $ScriptName, $Timeout, $Script, $Script_Type, $OS, $Architecture, $Varibles) {
    Write-Host("Updating Script named " + $ScriptName)
    $endpointURL = $URL + "/mdm/scripts/" + $CurrentScriptUUID
    if($Varibles){
        $KeyValuePair = $Varibles.Split(";")
        $VaribleBody = @()
        foreach ($i in $KeyValuePair){
            $Key = $i.Split(",")[0]
            $Value = $i.Split(",")[1]
            $VaribleBody += @{
                'name'  = $Key;
                'value' = $Value;
            }
        }
    }
    if(!$Architecture){$Architecture="UNKNOWN"}
    $body = @{
        'name'	                  = "$ScriptName";
        'description'             = "$Description";
        'platform'	              = "$OS";
        'script_type'	          = "$Script_Type";
        'platform_architecture'   = "$Architecture";
        'execution_context'	      = "$Context";
        'script_data'	          = "$Script";
        'timeout'	              = "$Timeout";
        'script_variables'        = $VaribleBody;
        'allowed_in_catalog'      = "$False";
            }
    $json = $body | ConvertTo-Json -Depth 20
    $webReturn = Invoke-RestMethod -Method Put -Uri $endpointURL -Headers $header -Body $json
    $Status = $webReturn
    Return $Status
}

# Assigns Scripts
Function Assign-Scripts($ScriptUUID, $SmartGroupUUID) {
    $endpointURL = $URL + "/mdm/scripts/"+$ScriptUUID+"/assignments"
    $EventsBody = @()
    if($LOGIN) {$EventsBody += "LOGIN"}
    if($LOGOUT) {$EventsBody += "LOGOUT"}
    if($STARTUP) {$EventsBody += "STARTUP"}
    if($RUN_IMMEDIATELY) {$EventsBody += "RUN_IMMEDIATELY"}
    if($NETWORK_CHANGE) {$EventsBody += "NETWORK_CHANGE"}
    $SmartGroupBody = @()
    $SmartGroupBody += @{ 'smart_group_uuid' = "$SmartGroupUUID" }
    if(!$SmartGroupName){$SmartGroupName = Get-SmartGroupName($SmartGroupID);}
    if(!$TriggerType) { $TriggerType = "SCHEDULE" }
    if($SCHEDULE) { $TriggerSchedule = $SCHEDULE }
    $body = [pscustomobject]@{
        'name'                    = $SmartGroupName;
        'priority'                = 0;
        'deployment_mode'         = "AUTO";
        'show_in_catalog'         = $false;
        'memberships'             = $SmartGroupBody;
        'script_deployment'       = @{
            'trigger_type'            = $TriggerType;
            'trigger_events'          = $EventsBody;
            'trigger_schedule'        = $TriggerSchedule;
                };
            }
    $json = $body | ConvertTo-Json
    $webReturn = Invoke-RestMethod -Method Post -Uri $endpointURL -Headers $headerv2 -Body $json
}

# Parse Local PowerShell Files
Function Get-LocalScripts {
    Write-Host("Parsing Local Files for Scripts")
    $Scripts = Select-String -Path $ScriptsDirectory\* -Pattern 'Execution Context' -Context 10000000 -ErrorAction SilentlyContinue
    Write-Host("Found " + $Scripts.Count + " Scripts Samples")
    Return $Scripts
}


# Check for Duplicates
Function Check-Duplicate-Script($ScriptName) {
    $ExisitingScripts = Get-Scripts
    if($ExisitingScripts){
    $Num = $ExisitingScripts.RecordCount -1
    $CurrentScripts = $ExisitingScripts.SearchResults
    $Duplicate = $False
    DO
    {
        $Result = $CurrentScripts[$Num].Name -eq $ScriptName
        if($Result){
            $Duplicate = $TRUE
            $global:CurrentScriptUUID = $CurrentScripts[$Num].script_uuid
        }
        $Num--
    } while ($Num -ge 0)
    }
    Return $Duplicate
}

# Delete all Scripts
Function Delete-Scripts() {
    $ExisitingScripts = Get-Scripts
    if($ExisitingScripts){
    $Num = $ExisitingScripts.RecordCount -1
    $CurrentScripts = $ExisitingScripts.SearchResults
    DO
    {
        $Script_UUID = $CurrentScripts[$Num].script_uuid
        $Script_Name = $CurrentScripts[$Num].Name
        if($Script_UUID){
            Write-Host("Deleting Script " + $Script_Name)
            $endpointURL = $URL + "/mdm/groups/"+ $WorkspaceONEGroupUUID +"/scripts/bulkdelete"
            $json = ConvertTo-Json @($Script_UUID)
            $webReturn = Invoke-RestMethod -Method Post -Uri $endpointURL -Headers $header -Body $json
            $Status = $webReturn
        }
        $Num--
    } while ($Num -ge 0)
    }
    Exit
}

# Gets Script's Details (Script Data)
Function Get-Script($UUID){
    $endpointURL = $URL + "/mdm/scripts/" + $UUID
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $Script = $webReturn
    Return $Script
}

# Downloads Scripts from Console Locally
Function Export-Scripts($path) {
$ConsoleScripts = Get-Scripts
$Num = $ConsoleScripts.RecordCount - 1
$ConsoleScripts = $ConsoleScripts.SearchResults
DO
    {  
    $ScriptUUID = $ConsoleScripts[$Num].script_uuid
    $Script = Get-Script($ScriptUUID)
    $ScriptBody = $Script.script_data
    Write-Host "Exporting $($Script.name)"
    switch ($Script.script_type){
        'POWERSHELL'
        {
            if($ScriptBody){[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($ScriptBody)) | Out-File -Encoding "UTF8" "$($download_path)\$($Script.Name).ps1" -Force}
        }
        '2'
        {
            if($ScriptBody){[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($ScriptBody)) | Out-File -Encoding "UTF8" "$($download_path)\$($Script.Name).py" -Force}
        }
        '4'
        {
            if($ScriptBody){[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($ScriptBody)) | Out-File -Encoding "UTF8" "$($download_path)\$($Script.Name).zsh" -Force}
        }
        '3'
        {
            if($ScriptBody){[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($ScriptBody)) | Out-File -Encoding "UTF8" "$($download_path)\$($Script.Name).sh" -Force}
        }
    }
    $Num--
    } While ($Num -ge 0)
}

Write-Host("*****************************************************************") -ForegroundColor Yellow 
Write-Host("Starting Up, let's get this done!") -ForegroundColor Yellow 
Write-Host("*****************************************************************") -ForegroundColor Yellow 

# Contruct REST HEADER
$header = @{
"Authorization"  = "Basic $cred";
"aw-tenant-code" = $WorkspaceONEAPIKey;
"Accept"		 = "application/json";
"Content-Type"   = "application/json";}

$headerv2 = @{
"Authorization"  = "Basic $cred";
"aw-tenant-code" = $WorkspaceONEAPIKey;
"Accept"		 = "application/json;version=2";
"Content-Type"   = "application/json";}

                
# Get ogID and UUID from Organizational Group Name
if ($WorkspaceONEOgId -eq $null){
    if($OrganizationGroupName){
        $WorkspaceONEOgId = Get-OrganizationIDbyName($OrganizationGroupName)
    }elseif($OrganizationGroupID){
        $WorkspaceONEOgId = Get-OrganizationIDbyID($OrganizationGroupID)
    }else{
        Write-Host("Please provide a value for OrganizationGroupName or OrganizationGroupID") -ForegroundColor Yellow 
        Exit
    }
}
$WorkspaceONEGroupUUID = Get-OrganizationGroupUUID($WorkspaceONEOgId)

# Checking for Supported Console Version
Check-ConsoleVersion

# Downloads Scripts Locally if using the -ExportScript parameter
if($ExportScripts){
$download_path = Read-Host -Prompt "Input path to download Script samples"
Export-Scripts($download_path)
Write-Host "Scripts have been downloaded to " $download_path -ForegroundColor Yellow
Write-Host("*****************************************************************") -ForegroundColor Yellow 
Write-Host("We did it! You are awesome, have a great day!") -ForegroundColor Yellow 
Write-Host("*****************************************************************") -ForegroundColor Yellow 
Exit
}

# Pull in PS Samples
$PSScripts = Get-LocalScripts

$NumScripts = $PSScripts.Count - 1
DO
{
# Removes file extension from filename
$ScriptName = ($PSScripts)[$NumScripts].Filename
switch -Regex ( $ScriptName )
{
    '^.*\.(ps1)$'
    {
        $Script_Type = "POWERSHELL"
        $os = "WIN_RT"
        $ScriptName = ($PSScripts)[$NumScripts].Filename -replace ".ps1",""
    }
    '^.*\.(py)$'
    {
        $Script_Type = "PYTHON"
        $os = "APPLE_OSX"
        $ScriptName = ($PSScripts)[$NumScripts].Filename -replace ".py",""
    }
    '^.*\.(zsh)$'
    {
        $Script_Type = "ZSH"
        $os = "APPLE_OSX"
        $ScriptName = ($PSScripts)[$NumScripts].Filename -replace ".zsh",""
    }
    '^.*\.(sh)$'
    {
        $ShaBang = ($PSScripts)[$NumScripts].Context.PreContext[0].ToLower()
        switch -Regex ( $ShaBang )
        {
            '^.*(\/bash)$'
            {
                $Script_Type = "BASH"
                $os = "APPLE_OSX"
                $ScriptName = ($PSScripts)[$NumScripts].Filename -replace ".sh",""
            }
            '^.*(\/zsh)$'
            {
                $Script_Type = "ZSH"
                $os = "APPLE_OSX"
                $ScriptName = ($PSScripts)[$NumScripts].Filename -replace ".zsh",""
            }
            default
            {
                $Script_Type = "BASH"
                $os = "APPLE_OSX"
                $ScriptName = ($PSScripts)[$NumScripts].Filename -replace ".sh",""
            }
        }
    }
    default # searches the sha-bang for scripts with no file extension 
    {
        $ShaBang = ($PSScripts)[$NumScripts].Context.PreContext[0].ToLower()
        switch -Regex ( $ShaBang )
        {
            '^.*(\/bash)$'
            {
                $Script_Type = "BASH"
                $os = "APPLE_OSX"
                $ScriptName = ($PSScripts)[$NumScripts].Filename -replace ".sh",""
            }
            '^.*(\/zsh)$'
            {
                $Script_Type = "ZSH"
                $os = "APPLE_OSX"
                $ScriptName = ($PSScripts)[$NumScripts].Filename -replace ".zsh",""
            }
            '^.*(\/python)$'
            {
                $Script_Type = "PYTHON"
                $os = "APPLE_OSX"
                $ScriptName = ($PSScripts)[$NumScripts].Filename -replace ".py",""
            }
            default
            {
                $Script_Type = "BASH"
                $os = "APPLE_OSX"
                $ScriptName = ($PSScripts)[$NumScripts].Filename -replace ".sh",""
            }
        }
    }
}


# If DeleteScripts switch is called, then deletes all Script samples
if ($DeleteScripts) {
    Delete-Scripts($WorkspaceONEOgId)
    Break
}elseif (Check-Duplicate-Script $ScriptName) {
    if($UpdateScripts){
    # Check if Script Already Exists
    Write-Host($ScriptName + " already exists in this tenant. Updating Script now!")
    # Removes Comment # and Quotes
    $Description = ($PSScripts)[$NumScripts].Context.PreContext[($PSScripts)[$NumScripts].Context.PreContext.Length - 1] -replace '[#]' -replace '"',"" -replace "'",""
    # USER, SYSTEM
    $Context = (($PSScripts)[$NumScripts].Line.ToUpper() -split ':')[1] -replace " ",""
    # EITHER_64BIT_OR_32BIT, ONLY_32BIT, ONLY_64BIT, LEGACY
    $Architecture = (($PSScripts[$NumScripts].Context.PostContext)[0].ToUpper() -split ':')[1] -replace " ",""
    # Timeout
    $Timeout = (($PSScripts[$NumScripts].Context.PostContext)[1] -split ':')[1] -replace " ",""
    # Varibles
    $Varibles = (($PSScripts[$NumScripts].Context.PostContext)[2] -split ':')[1] -replace " ",""
    # Encode Script
    $Data = Get-Content ($ScriptsDirectory.ToString() + "\" + ($PSScripts)[$NumScripts].Filename.ToString()) -Encoding UTF8 -Raw
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
    $Script = [Convert]::ToBase64String($Bytes)
        if( !$Platform -or (($Platform -eq 'Windows' -and $OS -eq 'WIN_RT') -or ($Platform -eq 'macOS' -and $OS -eq 'APPLE_OSX'))){
            Update-Scripts $Description $Context $ScriptName $Timeout $Script $Script_Type $OS $Architecture $Varibles
        }else{
            Write-Host($ScriptName + " isn't for " + $Platform + ". Skipping!") -ForegroundColor Yellow
        }
    }
    # Skips Template files
}elseif ($ScriptName -match "import_script_samples|sample|README.md"){
    Write-Host($ScriptName + " is a template. Skipping Templates.") -ForegroundColor Yellow 
}else{ # Adds new Scripts
    # Removes Comment # and Quotes
    $Description = ($PSScripts)[$NumScripts].Context.PreContext[($PSScripts)[$NumScripts].Context.PreContext.Length - 1] -replace '[#]' -replace '"',"" -replace "'",""
    # USER, SYSTEM
    $Context = (($PSScripts)[$NumScripts].Line.ToUpper() -split ':')[1] -replace " ",""
    # EITHER_64BIT_OR_32BIT, ONLY_32BIT, ONLY_64BIT, LEGACY
    $Architecture = (($PSScripts[$NumScripts].Context.PostContext)[0].ToUpper() -split ':')[1] -replace " ",""
    #Timeout
    $Timeout = (($PSScripts[$NumScripts].Context.PostContext)[1] -split ':')[1] -replace " ",""
    #Varibles
    $Varibles = (($PSScripts[$NumScripts].Context.PostContext)[2] -split ':')[1] -replace " ",""
    # Encode Script
    $Data = Get-Content ($ScriptsDirectory.ToString() + "\" + ($PSScripts)[$NumScripts].Filename.ToString()) -Encoding UTF8 -Raw
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
    $Script = [Convert]::ToBase64String($Bytes)
        if( !$Platform -or (($Platform -eq 'Windows' -and $OS -eq 'WIN_RT') -or ($Platform -eq 'macOS' -and $OS -eq 'APPLE_OSX'))){
            Set-Scripts $Description $Context $ScriptName $Timeout $Script $Script_Type $OS $Architecture $Varibles
        }else{
            Write-Host($ScriptName + " isn't for " + $Platform + ". Skipping!") -ForegroundColor Yellow
        }
}
$NumScripts--
} While ($NumScripts -ge 0)

# Assign Scripts to Smart Group
if(($SmartGroupID -ne 0) -or $SmartGroupName)
{
Write-Host("Assigning Scripts to Smart Group")
if($SmartGroupID){
    $SmartGroupUUID = Get-SmartGroupUUIDbyID $SmartGroupID
}elseif($SmartGroupName){
    $SmartGroupUUID = Get-SmartGroupUUIDbyName $SmartGroupName $WorkspaceONEOgId
}else{
    Write-Host("Please check your values for SmartGroupID or SmartGroupName") -ForegroundColor Yellow 
    Exit
}
$Scripts=Get-Scripts
$Num = $Scripts.RecordCount -1
$Scripts = $Scripts.SearchResults
    DO
    {
    $ScriptsUUID=$Scripts[$Num].script_uuid
    Assign-Scripts $ScriptsUUID $SmartGroupUUID
    $Num--
    } while ($Num -ge 0)
}

Write-Host("*****************************************************************") -ForegroundColor Yellow 
Write-Host("We did it! You are awesome, have a great day!") -ForegroundColor Yellow 
Write-Host("*****************************************************************") -ForegroundColor Yellow 