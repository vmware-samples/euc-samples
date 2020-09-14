<# Workspace ONE Sensors Importer

# Author:  Josue Negron - jnegron@vmware.com
# Contributors: Chris Halstead - chealstead@vmware.com
# Created: December 2018
# Updated: May 2020
# Version 1.3

  .SYNOPSIS
    This Powershell script allows you to automatically import PowerShell scripts as Workspace ONE Sensors in the Workspace ONE UEM Console. 
    MUST RUN AS ADMIN

  .DESCRIPTION
    Place this PowerShell script in the same directory of all of your samples (.ps1 files) or use the -SensorsDirectory parameter to specify your directory. 
    This script when run will parse the PowerShell sample scripts, check if they already exist, then upload to Workspace ONE UEM via the REST API. You can 
    leverage the optional switch parameters to update Sensors or delete all sensors. 

  .EXAMPLE

    .\import_sensor_samples.ps1 `
        -WorkspaceONEServer "https://as###.awmdm.com" `
        -WorkspaceONEAdmin "administrator" `
        -WorkspaceONEAdminPW "P@ssw0rd" `
        -WorkspaceONEAPIKey "7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E=" `
        -OrganizationGroupName "techzone" `
        -SmartGroupID "41" `
        -UpdateSensors

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
    The Group ID of the Organization Group. You can find this by hovering over your Organization's Name in the console.

    .PARAMETER SensorsDirectory
    OPTIONAL: The directory your .ps1 sensors samples are located, default location is the current PowerShell directory of this script. 

    .PARAMETER SmartGroupID
    OPTIONAL: If provided, all sensors in your environment will be assigned to this Smart Group. Exisiting assignments will be overwritten. 
    
    .PARAMETER DeleteSensors
    OPTIONAL: If enabled, all sensors in your environment will be deleted. This action cannot be undone. Ensure you are targeting the correct Organization Group. 
    
    .PARAMETER UpdateSensors
    OPTIONAL: If enabled, all sensors that match will be updated with the version in the PowerShell samples. 

    .PARAMETER ExportSensors
    OPTIONAL: If enabled, all sensors will be downloaded locally, this is a good option for backuping up sensors before making updates. 
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

        [Parameter(Mandatory=$True)]
        [string]$OrganizationGroupName, 

        [Parameter(Mandatory=$False)]
        [string]$SensorsDirectory, 

        [Parameter(Mandatory=$False)]
        [string]$SmartGroupID, 

        [Parameter(Mandatory=$False)]
        [switch]$UpdateSensors, 

        [Parameter(Mandatory=$False)]
        [switch]$DeleteSensors, 

        [Parameter(Mandatory=$False)]
        [switch]$ExportSensors
)

# Forces the use of TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$URL = $WorkspaceONEServer + "/api"
$global:CurrentSensorUUID = ""

# If a custom sensors directory is not provided then use current directory of import_sensor_samples.ps1 
if (!$SensorsDirectory) {$SensorsDirectory = Get-Location}

# Base64 Encode Workspace ONE UEM Username and Password for API Access
$combined = $WorkspaceONEAdmin + ":" + $WorkspaceONEAdminPW
$encoding = [System.Text.Encoding]::ASCII.GetBytes($combined)
$cred = [Convert]::ToBase64String($encoding)

# Returns the Numerial Group ID for the Organizational Group ID Provided
Function Get-OrganizationGroupID {
    Write-Host("Getting Group ID from Group Name")
    $endpointURL = $URL + "/system/groups/search?groupID=" + $organizationGroupName
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $totalReturned = $webReturn.Total
    $groupID = -1
    If ($webReturn.Total = 1) {
        $groupID = $webReturn.LocationGroups.Id.Value
        Write-Host("Group ID for " + $organizationGroupName + " = " + $groupID)
    } else {
        Write-host("Group Name: " + $organizationGroupName + " not found")
    }
    Return $groupID
}

# Returns the UUID of the Group ID Provided
Function Get-OrganizationGroupUUID($groupID) {
    Write-Host("Getting Group UUID from Group Name")
    $endpointURL = $URL + "/system/groups/" + $groupID
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $groupUUID = $webReturn.Uuid
    Return $groupUUID
}

# Returns the UUID of the Smart Group Provided
Function Get-SmartGroupUUID($SmartGroupID) {
    Write-Host("Getting Group UUID from Group Name")
    $endpointURL = $URL + "/mdm/smartgroups/" + $SmartGroupID
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $SmartGroupUUID = $webReturn.SmartGroupUuid
    Return $SmartGroupUUID
}

# Checks Sensors Status
Function Check-SensorsEnabled($WorkspaceONEGroupUUID) {
    Write-Host("Checking Sensors Status")
    $endpointURL = $URL + "/system/featureflag/DeviceSensorsFeatureFlag/" + $WorkspaceONEGroupUUID
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $SensorsStatus = $webReturn.isEnabled
    if ($SensorsStatus = $false) {
        Write-Host("Sensors is not Enabled in your environment. Please reach out to your Workspace ONE rep to have it enabled.") -ForegroundColor Yellow 
        Exit
    }else{
        Write-Host("Sensors is Enabled")
        Return $null
    }
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

# Returns a list of Sensors
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

# Creates a new Sensor
Function Set-Sensors($Description, $Context, $SensorName, $ResponseType, $Script) {
    Write-Host("Creating new Sensor " + $SensorName)
    $endpointURL = $URL + "/mdm/devicesensors/"
    $body = @{
        'description'             = "$Description";
        'execution_context'	      = "$Context";
        'name'	                  = "$SensorName";
        'organization_group_uuid' =	"$WorkspaceONEGroupUUID";
        'platform'	              = "WIN_RT";
        'query_response_type'	  = "$ResponseType";
        'query_type'	          = "POWERSHELL";
        'script_data'	          = "$Script";
        'trigger_type'	          = "SCHEDULE";
            }
    $json = $body | ConvertTo-Json
    $webReturn = Invoke-RestMethod -Method Post -Uri $endpointURL -Headers $header -Body $json
    $Status = $webReturn
    Return $Status
}

# Updates Exisiting Sensors
Function Update-Sensors($Description, $Context, $SensorName, $ResponseType, $Script) {
    Write-Host("Creating new Sensor " + $SensorName)
    $endpointURL = $URL + "/mdm/devicesensors/" + $CurrentSensorUUID
    $body = @{
        'description'             = "$Description";
        'execution_context'	      = "$Context";
        'name'	                  = "$SensorName";
        'organization_group_uuid' =	"$WorkspaceONEGroupUUID";
        'platform'	              = "WIN_RT";
        'query_response_type'	  = "$ResponseType";
        'query_type'	          = "POWERSHELL";
        'script_data'	          = "$Script";
        'trigger_type'	          = "SCHEDULE";
        'uuid'                    = "$CurrentSensorUUID";
            }
    $json = $body | ConvertTo-Json
    $webReturn = Invoke-RestMethod -Method Put -Uri $endpointURL -Headers $header -Body $json
    $Status = $webReturn
    Return $Status
}

# Assigns Sensors
Function Assign-Sensors($SensorUUID, $SmartGroupUUID) {
    $endpointURL = $URL + "/mdm/devicesensors/assign"
    $SensorBody = @()
    $SensorBody += "$SensorUUID" 
    $SmartBody = @()
    $SmartBody += "$SmartGroupUUID"
    $body = [pscustomobject]@{
        'device_sensors'          = $SensorBody;
        'organization_group_uuid' = "$WorkspaceONEGroupUUID";
        'smart_groups'	          = $SmartBody;
            }
    $json = $body | ConvertTo-Json
    $webReturn = Invoke-RestMethod -Method Post -Uri $endpointURL -Headers $header -Body $json
}

# Parse PowerShell Files
Function Get-PowerShellSensors {
    Write-Host("Parsing PowerShell Scripts")
    $PSSensors = Select-String -Path $SensorsDirectory\*.ps1 -Pattern 'Return Type' -Context 10000000
    Write-Host("Found " + $PSSensors.Count + " PowerShell Samples")
    Return $PSSensors
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
        $Result = $CurrentSensors[$Num].Name -match $SensorName
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
                'Sensor_uuids'	          = $SensorBody;
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
    if($ScriptBody){[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($ScriptBody)) | Out-File -Encoding "UTF8" "$($download_path)\$($Sensor.Name).ps1" -Force}
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
"Content-Type"   = "application/json;version=2";}
                
# Get GroupID and UUID from Organizational Group Name
if ($WorkspaceONEGroupID -eq $null){$WorkspaceONEGroupID = Get-OrganizationGroupID($WorkspaceONEGroupID)}
$WorkspaceONEGroupUUID = Get-OrganizationGroupUUID($WorkspaceONEGroupID)

# Checking for Supported Console Version and if Sensors is Enabled
# Check-ConsoleVersion
# Check-SensorsEnabled($WorkspaceONEGroupUUID)

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
 $PSSensors = Get-PowerShellSensors

$NumSensors = $PSSensors.Count - 1
DO
    {
    # Removes .ps1 from filename, convert to lowercase, replace spaces with underscores
    $SensorName = ($PSSensors)[$NumSensors].Filename.ToLower() -replace ".ps1","" -replace “ “,”_”
    # If DeleteSensors switch is called, then deletes all Sensor samples
    if ($DeleteSensors) {
        Delete-Sensors($WorkspaceONEGroupID)
        Break
    }elseif (Check-Duplicate-Sensor $SensorName) {
        if($UpdateSensors){
        # Check if Sensor Already Exists
        Write-Host($SensorName + " already exists in this tenant. Updating Sensor now!")
        # Removes Comment # and Quotes
        $Description = ($PSSensors)[$NumSensors].Context.PreContext -replace '[#]' -replace '"',"" -replace "'",""
        # INTEGER, BOOLEAN, STRING, DATETIME
        $ResponseType = (($PSSensors)[$NumSensors].Line.ToUpper() -split ':')[1] -replace " ",""
        # USER, SYSTEM, ADMIN
        $Context = (($PSSensors[$NumSensors].Context.PostContext)[0].ToUpper() -split ':')[1] -replace " ",""
        # Encode Script
        $Data = Get-Content ($SensorsDirectory.ToString() + "\" + ($PSSensors)[$NumSensors].Filename.ToString()) -Encoding UTF8 -Raw
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
        $Script = [Convert]::ToBase64String($Bytes)
        Update-Sensors $Description $Context $SensorName $ResponseType $Script
        }
        # Skips Template files
    }elseif ($SensorName -match "template_get_registry_value|template_get_wmi_object|import_sensor_samples"){
        Write-Host($SensorName + " is a template. Skipping Templates.") -ForegroundColor Yellow 
    }else{ # Adds new Sensors
        # Removes Comment # and Quotes
        $Description = ($PSSensors)[$NumSensors].Context.PreContext -replace '[#]' -replace '"',"" -replace "'",""
        # INTEGER, BOOLEAN, STRING, DATETIME
        $ResponseType = (($PSSensors)[$NumSensors].Line.ToUpper() -split ':')[1] -replace " ",""
        # USER, SYSTEM, ADMIN
        $Context = (($PSSensors[$NumSensors].Context.PostContext)[0].ToUpper() -split ':')[1] -replace " ",""
        # Encode Script
        $Data = Get-Content ($SensorsDirectory.ToString() + "\" + ($PSSensors)[$NumSensors].Filename.ToString()) -Encoding UTF8 -Raw
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
        $Script = [Convert]::ToBase64String($Bytes)
        Set-Sensors $Description $Context $SensorName $ResponseType $Script
    }
    $NumSensors--
    } While ($NumSensors -ge 0)

# Assign Sensors to Smart Group
if($SmartGroupID)
{
    Write-Host("Assigning Sensors to Smart Group")
    $SmartGroupUUID = Get-SmartGroupUUID $SmartGroupID
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