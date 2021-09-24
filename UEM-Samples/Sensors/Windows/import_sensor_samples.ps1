<# Workspace ONE Sensors Importer

# Author:  Josue Negron - jnegron@vmware.com
# Contributors: Chris Halstead - chealstead@vmware.com
# Created: December 2018
# Updated: Feb. 1 2021
# Version 3.3

  .SYNOPSIS
    This Powershell script allows you to automatically import PowerShell scripts as Workspace ONE Sensors in the Workspace ONE UEM Console. 
    MUST RUN AS ADMIN

  .DESCRIPTION
    Place this PowerShell script in the same directory of all of your samples (.ps1, .sh, .zsh, .py files) or use the -SensorsDirectory parameter to specify your directory. 
    This script when run will parse the PowerShell sample scripts, check if they already exist, then upload to Workspace ONE UEM via the REST API. You can 
    leverage the optional switch parameters to update Sensors or delete all sensors. 

  .EXAMPLE

    .\import_sensor_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin "administrator" `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone' `
        -SmartGroupName 'All Devices' `
        -UpdateSensors `
        -TriggerType 'EVENT' `
        -LOGIN -LOGOUT

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

    .PARAMETER SensorsDirectory
    OPTIONAL: The directory your .ps1 sensors samples are located, default location is the current PowerShell directory of this script. 

    .PARAMETER SmartGroupID
    OPTIONAL: If provided, all scripts in your environment will be assigned to this Smart Group. Exisiting assignments will be overwritten. 
    If wanting to assigned, you are required to provide SmartGroupID or SmartGroupName.

    .PARAMETER SmartGroupID
    OPTIONAL: If provided, all scripts in your environment will be assigned to this Smart Group. Exisiting assignments will be overwritten. 
    If wanting to assigned, you are required to provide SmartGroupID or SmartGroupName.
    
    .PARAMETER DeleteSensors
    OPTIONAL: If enabled, all sensors in your environment will be deleted. This action cannot be undone. Ensure you are targeting the correct Organization Group. 
    
    .PARAMETER UpdateSensors
    OPTIONAL: If enabled, all sensors that match will be updated with the version in the PowerShell samples. 

    .PARAMETER ExportSensors
    OPTIONAL: If enabled, all sensors will be downloaded locally, this is a good option for backuping up sensors before making updates. 

    .PARAMETER Platform
    OPTIONAL: Keep disabled to import all platforms. If enabled, determines what platform's sensors to import. Supported values are "Windows" or "macOS".  
    
    .PARAMETER TriggerType
    OPTIONAL: When bulk assigning, provide the Trigger Type: 'SCHEDULE', 'EVENT', or 'SCHEDULEANDEVENT'

    .PARAMETER LOGIN
    OPTIONAL: When using 'Event' as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', or 'USER_SWITCH'

    .PARAMETER LOGOUT
    OPTIONAL: When using 'Event' as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', or 'USER_SWITCH'
    
    .PARAMETER STARTUP
    OPTIONAL: When using 'Event' as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', or 'USER_SWITCH'
    
    .PARAMETER USER_SWITCH
    OPTIONAL: When using 'Event' as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', or 'USER_SWITCH'
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
        [string]$SensorsDirectory, 

        [Parameter(Mandatory=$False)]
        [int]$SmartGroupID, 

        [Parameter(Mandatory=$False)]
        [string]$SmartGroupName,  

        [Parameter(Mandatory=$False)]
        [switch]$UpdateSensors, 

        [Parameter(Mandatory=$False)]
        [switch]$DeleteSensors,

        [Parameter(Mandatory=$False)]
        [switch]$ExportSensors,

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
        [switch]$USER_SWITCH
)

# Forces the use of TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$URL = $WorkspaceONEServer + "/API"
$global:CurrentSensorUUID = ""

# If a custom sensors directory is not provided then use current directory of import_sensor_samples.ps1 
if (!$SensorsDirectory) {$SensorsDirectory = Get-Location}

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
    if ($Version -ge 18110) {
        Write-Host("Console Version " + $ProductVersion)
        Return $null
    }else{
        Write-Host("Your Console Version is " + $ProductVersion + " Sensors only works on Console Version 18.11.0.0 or above.") -ForegroundColor Yellow 
        $Response = Read-Host "Would you like to continue anyways? Only continue if you are sure you are running 18.11+ ( y / n )" 
    Switch ($Response) 
     { 
       Y {Write-host "Yes, Continuing Anyways"; Return $null} 
       N {Write-Host "Exiting Script"; Exit} 
       Default {Write-Host "Exiting Script"; Exit} 
     } 
    }
}

# Returns a list of Sensors from Workspace ONE UEM Console
Function Get-Sensors {
    Write-Host("Getting List of Sensors")
    $endpointURL = $URL + "/mdm/devicesensors/list/" + $WorkspaceONEGroupUUID
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $Sensors = $webReturn
    if($Sensors){
        Write-Host($Sensors.total_results.toString() + " Sensors Found in Console")
    }ELSE{
        Write-Host("No Sensors Found in Console")}
    Return $Sensors
}

# Creates a new Sensor to the Workspace ONE UEM Console
Function Set-Sensors($Description, $Context, $SensorName, $ResponseType, $Script, $query_type, $os) {
    Write-Host("Creating new Sensor " + $SensorName)
    $endpointURL = $URL + "/mdm/devicesensors/"
    $body = @{
        'description'             = "$Description";
        'execution_architecture'  = "EITHER64OR32BIT";
        'execution_context'	      = "$Context";
        'name'	                  = "$SensorName";
        'organization_group_uuid' =	"$WorkspaceONEGroupUUID";
        'platform'	              = "$os";
        'query_response_type'	  = "$ResponseType";
        'query_type'	          = "$query_type";
        'script_data'	          = "$Script";
            }
    $json = $body | ConvertTo-Json
    $webReturn = Invoke-RestMethod -Method Post -Uri $endpointURL -Headers $headerv2 -Body $json
    $Status = $webReturn
    Return $Status
}

# Updates Exisiting Sensors in the Workspace ONE UEM Console
Function Update-Sensors($Description, $Context, $SensorName, $ResponseType, $Script, $query_type, $os) {
    Write-Host("Creating new Sensor " + $SensorName)
    $endpointURL = $URL + "/mdm/devicesensors/" + $CurrentSensorUUID
    $body = @{
        'description'             = "$Description";
        'execution_architecture'  = "EITHER64OR32BIT";
        'execution_context'	      = "$Context";
        'name'	                  = "$SensorName";
        'organization_group_uuid' =	"$WorkspaceONEGroupUUID";
        'platform'	              = "$os";
        'query_response_type'	  = "$ResponseType";
        'query_type'	          = "$query_type";
        'script_data'	          = "$Script";
        'uuid'                    = "$CurrentSensorUUID";
            }
    $json = $body | ConvertTo-Json
    $webReturn = Invoke-RestMethod -Method Put -Uri $endpointURL -Headers $headerv2 -Body $json
    $Status = $webReturn
    Return $Status
}

# Assigns Sensors
Function Assign-Sensors($SensorUUID, $SmartGroupUUID) {
    $endpointURL = $URL + "/mdm/devicesensors/"+$SensorUUID+"/assignment"
    $EventsBody = @()
    if($LOGIN) {$EventsBody += "LOGIN"}
    if($LOGOUT) {$EventsBody += "LOGOUT"}
    if($STARTUP) {$EventsBody += "STARTUP"}
    if($USER_SWITCH) {$EventsBody += "USER_SWITCH"}
    $SmartBody = @()
    $SmartBody += "$SmartGroupUUID"
    if(!$SmartGroupName){$SmartGroupName = Get-SmartGroupName($SmartGroupID);}
    if(!$TriggerType) { $TriggerType = "SCHEDULE" }
    $body = [pscustomobject]@{
        'name'                    = $SmartGroupName;
        'smart_group_uuids'	      = $SmartBody;
        'trigger_type'            = $TriggerType;
        'event_triggers'          = $EventsBody;
            }
    $json = $body | ConvertTo-Json
    $header = @{
        "Authorization"  = "Basic $cred";
        "aw-tenant-code" = $WorkspaceONEAPIKey;
        "Accept"		 = "application/json;version=2";
        "Content-Type"   = "application/json";}
    $webReturn = Invoke-RestMethod -Method Post -Uri $endpointURL -Headers $header -Body $json
}

# Parse Local PowerShell Files
Function Get-LocalSensors {
    Write-Host("Parsing Local Files for Sensors")
    $Sensors = Select-String -Path $SensorsDirectory\* -Pattern 'Return Type' -Context 10000000 -ErrorAction SilentlyContinue
    Write-Host("Found " + $Sensors.Count + " Sensor Samples")
    Return $Sensors
}


# Check for Duplicates
Function Check-Duplicate-Sensor($SensorName) {
    $ExisitingSensors = Get-Sensors
    if($ExisitingSensors){
    $Num = $ExisitingSensors.total_results -1
    $CurrentSensors = $ExisitingSensors.result_set
    $Duplicate = $False
    DO
    {
        $Result = $CurrentSensors[$Num].Name -eq $SensorName
        if($Result){
            $Duplicate = $TRUE
            $global:CurrentSensorUUID = $CurrentSensors[$Num].UUID
        }
        $Num--
    } while ($Num -ge 0)
    }
    Return $Duplicate
}

# Delete all Sensors
Function Delete-Sensors() {
    $ExisitingSensors = Get-Sensors
    if($ExisitingSensors){
    $Num = $ExisitingSensors.total_results -1
    $CurrentSensors = $ExisitingSensors.result_set
    DO
    {
        $SensorUUID = $CurrentSensors[$Num].UUID
        $SensorName = $CurrentSensors[$Num].Name
        if($SensorUUID){
            Write-Host("Deleting Sensor " + $SensorName)
            $endpointURL = $URL + "/mdm/devicesensors/bulkdelete"
            $SensorBody = @()
            $SensorBody += "$SensorUUID"
            $body = [pscustomobject]@{
                'organization_group_uuid' = "$WorkspaceONEGroupUUID";
                'sensor_uuids'	          = $SensorBody;
            }
            $json = $body | ConvertTo-Json
            $webReturn = Invoke-RestMethod -Method Post -Uri $endpointURL -Headers $header -Body $json
            $Status = $webReturn
        }
        $Num--
    } while ($Num -ge 0)
    }
    Return $Status
}

# Gets Sensor's Details (Script Data)
Function Get-Sensor($UUID){
    $endpointURL = $URL + "/mdm/devicesensors/" + $UUID
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $Sensor = $webReturn
    Return $Sensor
}

# Downloads Sensors from Console Locally
Function Export-Sensors($path) {
$ConsoleSensors = Get-Sensors
$Num = $ConsoleSensors.total_results - 1
$ConsoleSensors = $ConsoleSensors.result_set
DO
    {  
    $UUID = $ConsoleSensors[$Num].uuid
    $Sensor = Get-Sensor($UUID)
    $ScriptBody = $Sensor.script_data
    Write-Host "Exporting $($Sensor.name)"
    switch ($Sensor.query_type){
        'POWERSHELL'
        {
            if($ScriptBody){[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($ScriptBody)) | Out-File -Encoding "UTF8" "$($download_path)\$($Sensor.Name).ps1" -Force}
        }
        '2'
        {
            if($ScriptBody){[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($ScriptBody)) | Out-File -Encoding "UTF8" "$($download_path)\$($Sensor.Name).py" -Force}
        }
        '4'
        {
            if($ScriptBody){[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($ScriptBody)) | Out-File -Encoding "UTF8" "$($download_path)\$($Sensor.Name).zsh" -Force}
        }
        '3'
        {
            if($ScriptBody){[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($ScriptBody)) | Out-File -Encoding "UTF8" "$($download_path)\$($Sensor.Name).sh" -Force}
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
#Check-ConsoleVersion

# Downloads Sensors Locally if using the -ExportSensor parameter
if($ExportSensors){
$download_path = Read-Host -Prompt "Input path to download Sensor samples"
Export-Sensors($download_path)
Write-Host "Sensors have been downloaded to " $download_path -ForegroundColor Yellow
Write-Host("*****************************************************************") -ForegroundColor Yellow 
Write-Host("We did it! You are awesome, have a great day!") -ForegroundColor Yellow 
Write-Host("*****************************************************************") -ForegroundColor Yellow 
Exit
}

# Pull in PS Samples
 $PSSensors = Get-LocalSensors

$NumSensors = $PSSensors.Count - 1
DO
{
# Removes .ps1 from filename, convert to lowercase, replace spaces with underscores
$SensorName = ($PSSensors)[$NumSensors].Filename.ToLower()
switch -Regex ( $SensorName )
{
    '^.*\.(ps1)$'
    {
        $query_type = "POWERSHELL"
        $os = "WIN_RT"
        $SensorName = ($PSSensors)[$NumSensors].Filename.ToLower() -replace ".ps1","" -replace " ","_"
    }
    '^.*\.(py)$'
    {
        $query_type = "PYTHON"
        $os = "APPLE_OSX"
        $SensorName = ($PSSensors)[$NumSensors].Filename.ToLower() -replace ".py","" -replace " ","_"
    }
    '^.*\.(zsh)$'
    {
        $query_type = "ZSH"
        $os = "APPLE_OSX"
        $SensorName = ($PSSensors)[$NumSensors].Filename.ToLower() -replace ".zsh","" -replace " ","_"
    }
    '^.*\.(sh)$'
    {
        #Add Logic to look into the first line of the file
        $ShaBang = ($PSSensors)[$NumSensors].Context.PreContext[0].ToLower()
        switch -Regex ( $ShaBang )
        {
            '^.*(\/bash)$'
            {
                $query_type = "BASH"
                $os = "APPLE_OSX"
                $SensorName = ($PSSensors)[$NumSensors].Filename.ToLower() -replace ".sh","" -replace " ","_"
            }
            '^.*(\/zsh)$'
            {
                $query_type = "ZSH"
                $os = "APPLE_OSX"
                $SensorName = ($PSSensors)[$NumSensors].Filename.ToLower() -replace ".zsh","" -replace " ","_"
            }
            default
            {
                $query_type = "BASH"
                $os = "APPLE_OSX"
                $SensorName = ($PSSensors)[$NumSensors].Filename.ToLower() -replace ".sh","" -replace " ","_"
            }
        }
    }
    default
    {
        $query_type = "BASH"
        $os = "APPLE_OSX"
        $SensorName = ($PSSensors)[$NumSensors].Filename.ToLower() -replace ".sh","" -replace " ","_"
    }
}


# If DeleteSensors switch is called, then deletes all Sensor samples
if ($DeleteSensors) {
    Delete-Sensors($WorkspaceONEOgId)
    Break
}elseif (Check-Duplicate-Sensor $SensorName) {
    if($UpdateSensors){
    # Check if Sensor Already Exists
    Write-Host($SensorName + " already exists in this tenant. Updating Sensor now!")
    # Removes Comment # and Quotes
    $Description = ($PSSensors)[$NumSensors].Context.PreContext[($PSSensors)[$NumSensors].Context.PreContext.Length - 1] -replace '[#]' -replace '"',"" -replace "'",""
    # INTEGER, BOOLEAN, STRING, DATETIME
    $ResponseType = (($PSSensors)[$NumSensors].Line.ToUpper() -split ':')[1] -replace " ",""
    # USER, SYSTEM, ADMIN
    $Context = (($PSSensors[$NumSensors].Context.PostContext)[0].ToUpper() -split ':')[1] -replace " ",""
    # Encode Script
    $Data = Get-Content ($SensorsDirectory.ToString() + "\" + ($PSSensors)[$NumSensors].Filename.ToString()) -Encoding UTF8 -Raw
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
    $Script = [Convert]::ToBase64String($Bytes)
        if( !$Platform -or (($Platform -eq 'Windows' -and $os -eq 'WIN_RT') -or ($Platform -eq 'macOS' -and $os -eq 'APPLE_OSX'))){
            Update-Sensors $Description $Context $SensorName $ResponseType $Script $query_type $os
        }else{
            Write-Host($SensorName + " isn't for " + $Platform + ". Skipping!") -ForegroundColor Yellow
        }
    }
    # Skips Template files
}elseif ($SensorName -match "template_get_registry_value|template_file_hash|template_get_folder_size|template_get_wmi_object|import_sensor_samples|get_enrollment_sid_32_64|check_matching_sid_sensor"){
    Write-Host($SensorName + " is a template. Skipping Templates.") -ForegroundColor Yellow 
}else{ # Adds new Sensors
    # Removes Comment # and Quotes
    $Description = ($PSSensors)[$NumSensors].Context.PreContext[($PSSensors)[$NumSensors].Context.PreContext.Length - 1] -replace '[#]' -replace '"',"" -replace "'",""
    # INTEGER, BOOLEAN, STRING, DATETIME
    $ResponseType = (($PSSensors)[$NumSensors].Line.ToUpper() -split ':')[1] -replace " ",""
    # USER, SYSTEM, ADMIN
    $Context = (($PSSensors[$NumSensors].Context.PostContext)[0].ToUpper() -split ':')[1] -replace " ",""
    # Encode Script
    $Data = Get-Content ($SensorsDirectory.ToString() + "\" + ($PSSensors)[$NumSensors].Filename.ToString()) -Encoding UTF8 -Raw
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
    $Script = [Convert]::ToBase64String($Bytes)
        if( !$Platform -or (($Platform -eq 'Windows' -and $os -eq 'WIN_RT') -or ($Platform -eq 'macOS' -and $os -eq 'APPLE_OSX'))){
            Set-Sensors $Description $Context $SensorName $ResponseType $Script $query_type $os
        }else{
            Write-Host($SensorName + " isn't for " + $Platform + ". Skipping!") -ForegroundColor Yellow
        }
}
$NumSensors--
} While ($NumSensors -ge 0)

# Assign Scripts to Smart Group
if(($SmartGroupID -ne 0) -or $SmartGroupName)
{
    Write-Host("Assigning Sensors to Smart Group")
    if($SmartGroupID){
        $SmartGroupUUID = Get-SmartGroupUUIDbyID $SmartGroupID
    }elseif($SmartGroupName){
        $SmartGroupUUID = Get-SmartGroupUUIDbyName $SmartGroupName $WorkspaceONEOgId
    }else{
        Write-Host("Please check your values for SmartGroupID or SmartGroupName") -ForegroundColor Yellow 
        Exit
    }
    $Sensors=Get-Sensors
    $Num = $Sensors.total_results -1
    $Sensors = $Sensors.result_set
        DO
        {
        $SensorsUUID=$Sensors[$Num].uuid
        Assign-Sensors $SensorsUUID $SmartGroupUUID
        $Num--
        } while ($Num -ge 0)
}

Write-Host("*****************************************************************") -ForegroundColor Yellow 
Write-Host("We did it! You are awesome, have a great day!") -ForegroundColor Yellow 
Write-Host("*****************************************************************") -ForegroundColor Yellow 