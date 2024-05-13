<# Workspace ONE Sensors Importer

  .SYNOPSIS
    This Powershell script allows you to automatically import Windows, macOS and Linux sensors into the Workspace ONE UEM Console. 
    MUST RUN AS ADMIN
  .NOTES
    Created:   	    January, 2021
    Created by:	    Josue Negron, jnegron@vmware.com, 
    Contributors:   Chris Halstead, chealstead@vmware.com; Phil Helmling, helmlingp@vmware.com
    Organization:   VMware, Inc.
    Filename:       import_sensor_samples.ps1
    Updated:        May 2024, helmlingp@vmware.com
    Github:         https://github.com/euc-oss/euc-samples/tree/main/UEM-Samples/Sensors


  .DESCRIPTION
    Place this PowerShell script in the same directory of all of your samples (.ps1, .sh, .zsh, .py files) or use the -SensorsDirectory parameter 
    to specify your directory. This script will parse the sensors, check if they already exist, then upload to Workspace ONE UEM via 
    the REST API. You can leverage the optional switch parameter -UpdateSensors to update the sensors included in the source directory, and assign them to the 
    specified Smart Group. There is also an ability to delete or export all sensors. 

    For Windows Samples be sure to use the following format when creating new samples so that they are imported correctly:
    # Description: Description
    # Execution Context: SYSTEM | USER
    # Execution Architecture: EITHER64OR32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY
    # Return Type: INTEGER | BOOLEAN | STRING | DATETIME
    <YOUR POWERSHELL COMMANDS>

    For macOS Samples be sure to use the following format when creating new samples so that they are imported correctly:
    <YOUR SCRIPT COMMANDS>
    # Description: Description
    # Execution Context: SYSTEM | USER
    # Return Type: INTEGER | BOOLEAN | STRING | DATETIME
    # Variables: KEY,VALUE; KEY,VALUE

    For Linux Samples be sure to use the following format when creating new samples so that they are imported correctly:
    <YOUR SCRIPT COMMANDS>
    # Description: Description
    # Execution Context: SYSTEM | USER
    # Return Type: INTEGER | BOOLEAN | STRING | DATETIME
    # Variables: KEY,VALUE; KEY,VALUE
    # Platform: LINUX

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
    VMWARE,INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
    OPTIONAL (Required to provide OrganizationGroupName or OrganizationGroupID):
    The display name of the Organization Group. You can find this at the top of the console, normally your company's name.
    This option will prompt to select the correct Organization Group if multiple OGs are found with a similar name.

    .PARAMETER OrganizationGroupID
    OPTIONAL (Required to provide OrganizationGroupName or OrganizationGroupID):
    The Group ID for your organization group. You can find this at the top of the console by hovering over the company name.
    This option will prompt to select the correct Organization Group if multiple OGs are found with a similar name.

    .PARAMETER SensorsDirectory
    OPTIONAL: The directory your sensor samples are located, default location is the current PowerShell directory of this script. 

    .PARAMETER SmartGroupID
    OPTIONAL: If provided, new & existing sensors that are not already assigned to this SmartGroup will be assigned.
    This option will prompt to select the correct Smart Group if multiple Smart Groups are found with a similar name.

    .PARAMETER SmartGroupName
    OPTIONAL: If provided, new & existing sensors that are not already assigned to this SmartGroup will be assigned.
    This option will prompt to select the correct Smart Group if multiple Smart Groups are found with a similar name.
    
    .PARAMETER DeleteSensors
    OPTIONAL: If enabled, all sensors in your environment will be deleted. This action cannot be undone. Ensure you are targeting the correct Organization Group. 
    
    .PARAMETER UpdateSensors
    OPTIONAL: If enabled, imported sensors will update matched sensors found in the Workspace ONE UEM Console.

    .PARAMETER ExportSensors
    OPTIONAL: If enabled, all sensors will be downloaded locally, this is a good option for backuping up sensors before making updates. 

    .PARAMETER Platform
    OPTIONAL: Keep disabled to import all platforms. If enabled, determines what platform's sensors to import. Supported values are "Windows", "macOS" or "Linux".  
    
    .PARAMETER TriggerType
    OPTIONAL: Required when using 'SmartGroupID' or 'SmartGroupName' paramaters. When bulk assigning, provide the Trigger Type: 'SCHEDULE' or 'EVENT'

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

# Returns the Numerial Organization ID for the Organizational Group Name Provided
Function Get-OrganizationIDbyName {
    param (
        [Parameter(Mandatory=$True)]
        [string]$OrganizationGroupName
    )
    # Get ogID and UUID from Organizational Group Name
    Write-Host("Getting Organization ID from Group Name")
    $endpointURL = $URL + "/system/groups/search?name=" + $OrganizationGroupName
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $headerv2
    $OGSearchOGs = $webReturn.OrganizationGroups
    $OGSearchTotal = $webReturn.TotalResults

    if ($OGSearchTotal -eq 0){
        Write-host("Group Name: " + $OrganizationGroupName + " not found")
    } elseif ($OGSearchTotal -eq 1){
        $Choice = 0
    } elseif ($OGSearchTotal -gt 1) {
        $ValidChoices = 0..($OGSearchOGs.Count -1)
        $ValidChoices += 'Q'
        Write-Host "`nMultiple OGs found. Please select an OG from the list:" -ForegroundColor Yellow
        $Choice = ''
        while ([string]::IsNullOrEmpty($Choice)) {
            $i = 0
            foreach ($OG in $OGSearchOGs) {
                Write-Host ('{0}: {1}       {2}       {3}' -f $i, $OG.name, $OG.GroupId, $OG.Country)
                $i += 1
            }

            $Choice = Read-Host -Prompt 'Type the number that corresponds to the OG you want, or Press "Q" to quit'
            if ($Choice -in $ValidChoices) {
                if ($Choice -eq 'Q'){
                Write-host " Exiting Script"
                exit
                } else {
                $Choice = $Choice
                }
            } else {
                [console]::Beep(1000, 300)
                Write-host ('    [ {0} ] is NOT a valid selection.' -f $Choice)
                Write-host '    Please try again ...'
                pause

                $Choice = ''
            }
        }
    }
    $getOG = $OGSearchOGs[$Choice]
    $script:OrganizationGroupName = $getOG.Name
    $script:WorkspaceONEOgId = $getOG.Id
    $script:WorkspaceONEGroupUUID = $getOG.Uuid
    Write-Host("`nOrganization ID for $OrganizationGroupName = $WorkspaceONEOgId with UUID = $WorkspaceONEGroupUUID") -ForegroundColor Green
}

# Returns the Numerial Organization ID Name & UUID for the Organizational Group ID Provided
Function Get-OrganizationIDbyID {
    param (
        [Parameter(Mandatory=$True)]
        [string]$OrganizationGroupID
    )
    Write-Host("Getting Organization ID from Group ID")
    #$endpointURL = $URL + "/system/groups/search?groupID=" + $OrganizationGroupID
    $endpointURL = $URL + "/system/groups/" + $OrganizationGroupID
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $headerv2
    $script:WorkspaceONEOgId = $webReturn.Id.Value
    If ($WorkspaceONEOgId -eq $OrganizationGroupID) {
        $script:OrganizationGroupName = $webReturn.Name
        $script:WorkspaceONEGroupUUID = $webReturn.Uuid
        Write-Host("Organization Name for $WorkspaceONEOgId = $OrganizationGroupName with UUID = $WorkspaceONEGroupUUID")
    } else {
        Write-host("Group ID: " + $OrganizationGroupID + " not found")
    }
}

# Returns the Numerical ID Name & UUID of the Smart Group Provided
Function Get-SmartGroupUUIDbyID {
    param (
        [Parameter(Mandatory=$True)]
        [string]$SGID
    )
    $endpointURL = $URL + "/mdm/smartgroups/" + $SGID.ToString()
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $script:SmartGroupID = $webReturn.SmartGroupID
    if ($SmartGroupID -eq $SGID) {
        $script:SmartGroupUUID = $webReturn.SmartGroupUuid
        $script:SmartGroupName = $webReturn.Name
        #Write-host("Smart Group Name for $SmartGroupID = $SmartGroupName with UUID = $SmartGroupUUID")
    } else {
        Write-host("Smart Group ID $SmartGroupID not found")
    }
}

# Returns the Numerical ID Name & UUID of the Smart Group Name Provided
Function Get-SmartGroupUUIDbyName {
    param (
        [Parameter(Mandatory=$True)]
        [string]$SGName,
        [Parameter(Mandatory=$True)]
        [string]$WorkspaceONEOgId
    )
    $endpointURL = $URL + "/mdm/smartgroups/search?name=" + $SGName + "&managedbyorganizationgroupid=" + $WorkspaceONEOgId
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $SGSearch = $webReturn.SmartGroups
    $SGSearchTotal = $webReturn.Total

    if ($SGSearchTotal -eq 0){
        Write-host("Smart Group Name: " + $SGName + " not found")
    } elseif ($SGSearchTotal -eq 1){
        $Choice = 0
    } elseif ($SGSearchTotal -gt 1) {
        $ValidChoices = 0..($SGSearch.Count -1)
        $ValidChoices += 'Q'
        Write-Host "`nMultiple Smart Groups found. Please select an SG from the list:" -ForegroundColor Yellow
        $Choice = ''
        while ([string]::IsNullOrEmpty($Choice)) {
            $i = 0
            foreach ($SG in $SGSearch) {
                Write-Host ('{0}: {1}       {2}       {3}' -f $i, $SG.Name, $SG.SmartGroupId, $SG.ManagedByOrganizationGroupName)
                $i += 1
            }

            $Choice = Read-Host -Prompt 'Type the number that corresponds to the SG you want, or Press "Q" to quit'
            if ($Choice -in $ValidChoices) {
                if ($Choice -eq 'Q'){
                Write-host " Exiting Script"
                exit
                } else {
                $Choice = $Choice
                }
            } else {
                [console]::Beep(1000, 300)
                Write-host ('    [ {0} ] is NOT a valid selection.' -f $Choice)
                Write-host '    Please try again ...'
                pause

                $Choice = ''
            }
        }
    }
    $getSG = $SGSearch[$Choice]
    $script:SmartGroupID = $getSG.SmartGroupID
    $script:SmartGroupUUID = $getSG.SmartGroupUuid
    $script:SmartGroupName = $getSG.Name
    #Write-host("Smart Group Name for $SmartGroupID = $SmartGroupName with UUID = $SmartGroupUUID")
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
        Write-Host("Console Version " + $ProductVersion) -ForegroundColor Green
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
    Write-Host("Getting List of Sensors in the Console")
    $endpointURL = $URL + "/mdm/devicesensors/list/" + $WorkspaceONEGroupUUID
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $headerv2
    $Sensors = $webReturn
    if($Sensors){
        Write-Host($Sensors.total_results.toString() + " sensors found in console") -ForegroundColor Green
    }ELSE{
        Write-Host("No Sensors Found in Console")}
    Return $Sensors
}

# Creates a new Sensor to the Workspace ONE UEM Console
Function Set-Sensors {
    param (
        [Parameter(Mandatory=$True)]
        [string]$Description,
        [Parameter(Mandatory=$True)]
        [string]$Context,
        [Parameter(Mandatory=$False)]
        [string]$Architecture = "EITHER64OR32BIT",
        [Parameter(Mandatory=$True)]
        [string]$SensorName,
        [Parameter(Mandatory=$True)]
        [string]$ResponseType,
        [Parameter(Mandatory=$True)]
        [string]$Script,
        [Parameter(Mandatory=$True)]
        [string]$query_type,
        [Parameter(Mandatory=$True)]
        [string]$os,
        [Parameter(Mandatory=$False)]
        [string]$Varibles
    )
    $endpointURL = $URL + "/mdm/devicesensors/"

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
    $body = @{
        'name'	                  = "$SensorName";
        'description'             = "$Description";
        'organization_group_uuid' =	"$WorkspaceONEGroupUUID";
        'execution_architecture'  = "$Architecture";
        'execution_context'	      = "$Context";
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
Function Update-Sensors {
    param (
        [Parameter(Mandatory=$True)]
        [string]$Description,
        [Parameter(Mandatory=$True)]
        [string]$Context,
        [Parameter(Mandatory=$False)]
        [string]$Architecture = "EITHER64OR32BIT",
        [Parameter(Mandatory=$True)]
        [string]$SensorName,
        [Parameter(Mandatory=$True)]
        [string]$ResponseType,
        [Parameter(Mandatory=$True)]
        [string]$Script,
        [Parameter(Mandatory=$True)]
        [string]$query_type,
        [Parameter(Mandatory=$True)]
        [string]$os,
        [Parameter(Mandatory=$False)]
        [string]$Varibles
    )
    #Write-Host("Creating new Sensor " + $SensorName)
    $endpointURL = $URL + "/mdm/devicesensors/" + $CurrentSensorUUID
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
    $body = @{
        'name'	                  = "$SensorName";
        'description'             = "$Description";
        'organization_group_uuid' =	"$WorkspaceONEGroupUUID";
        'execution_architecture'  = "$Architecture";
        'execution_context'	      = "$Context";
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

# Returns list of SG assignments to a Sensor
function get-SensorAssignments {
    param (
        [Parameter(Mandatory=$True)]
        [string]$SensorUUID
    )
    $endpointURL = $URL + "/mdm/devicesensors/$SensorUUID/assignments"
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $headerv2
    $assignments = $webReturn.assigned_smart_groups
    return $assignments
}

# Assigns Sensors
Function Assign-Sensor {
    param (
        [Parameter(Mandatory=$True)]
        [string]$SensorUUID
    )
    $endpointURL = $URL + "/mdm/devicesensors/$SensorUUID/assignment"
    
    $EventsBody = @()
    if(!$TriggerType) { 
        $TriggerType = "SCHEDULE" 
    } elseif ($TriggerType = "EVENT") {
        if($LOGIN) {$EventsBody += "LOGIN"}
        if($LOGOUT) {$EventsBody += "LOGOUT"}
        if($STARTUP) {$EventsBody += "STARTUP"}
        if($USER_SWITCH) {$EventsBody += "USER_SWITCH"}
    }

    $SmartGroupBody = @()
    $SmartGroupBody += "$SmartGroupUUID"
    
    $body = [pscustomobject]@{
        'name'                    = $SmartGroupName;
        'smart_group_uuids'	      = $SmartGroupBody;
        'trigger_type'            = $TriggerType;
        'event_triggers'          = $EventsBody;
            }
    $json = $body | ConvertTo-Json
    $webReturn = Invoke-RestMethod -Method Post -Uri $endpointURL -Headers $headerv2 -Body $json
    return $webReturn
}

# Parse Local PowerShell Files
Function Get-LocalSensors {
    Write-Host("Parsing Local Files for Sensors")
    #$Sensors = Select-String -Path $SensorsDirectory\* -Pattern 'Return Type' -Context 10000000 -ErrorAction SilentlyContinue
    $ExcludedcTemplates = "import_sensor_samples|get_enrollment_sid_32_64|check_matching_sid_sensor|template*"
    $Sensors = Get-ChildItem -File | Where-Object Name -NotMatch $ExcludedcTemplates
    Write-Host("Found " + $Sensors.Count + " Sensors in local folder") -ForegroundColor Green
    Return $Sensors
}

# Check for Duplicates
Function Check-Duplicate-Sensor {
    param (
        [Parameter(Mandatory=$True)]
        [string]$SensorName
    )
    $Duplicate = $False
    DO
    {
        $Result = $CurrentSensors[$Num].Name -eq $SensorName
        if($Result){
            $Duplicate = $True
            $script:CurrentSensorUUID = $CurrentSensors[$Num].UUID
            $script:CurrentSensorAssignmentCount = $CurrentSensors[$Num].assignment_count
        }
        $Num--
    } while ($Num -ge 0)
    #}
    Return $Duplicate
}

# Delete all Sensors
Function Delete-Sensors {
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
Function Get-Sensor {
    param (
        [Parameter(Mandatory=$True)]
        [string]$SensorUUID
    )
    $endpointURL = $URL + "/mdm/devicesensors/" + $SensorUUID
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
        $SensorUUID = $ConsoleSensors[$Num].uuid
        $Sensor = Get-Sensor -SensorUUID $SensorUUID
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
        #export the execution context, execution architecture, return type etc and automatically add as comment to exported file
        $Num--
    } While ($Num -ge 0)
}

# Display usage info
Function usage {
    param (
        [Parameter(Mandatory=$True)]
        [string]$ScriptName
    )

    Write-Host("*****************************************************************") -ForegroundColor Yellow 
    Write-Host("               $SensorName Header Missing ") -ForegroundColor Yellow 
    Write-Host("*****************************************************************") -ForegroundColor Yellow 
    Write-Host "`rPlease ensure that $SensorName script includes the required header so that it can be imported correctly.`r" -ForegroundColor Yellow

    Write-Host "Example Windows Sensor Header`r" -ForegroundColor Green
    Write-Host "# Description: Description`r"
    Write-Host "# Execution Context: System | User`r"
    Write-Host "# Execution Architecture: EITHER64OR32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY`r"
    Write-Host "# Return Type: INTEGER | BOOLEAN | STRING | DATETIME`r"
    Write-Host "<YOUR POWERSHELL COMMANDS>`r`n"

    Write-Host "Example macOS Sensor Header`r" -ForegroundColor Green
    Write-Host "<YOUR SCRIPT COMMANDS>`r"
    Write-Host "# Description: Description`r"
    Write-Host "# Execution Context: System | User`r"
    Write-Host "# Return Type: INTEGER | BOOLEAN | STRING | DATETIME`r"
    Write-Host "# Variables: KEY,VALUE; KEY,VALUE`r"

    Write-Host "Example Linux Sensor Header`r" -ForegroundColor Green
    Write-Host "<YOUR SCRIPT COMMANDS>`r"
    Write-Host "# Description: Description`r"
    Write-Host "# Execution Context: System | User`r"
    Write-Host "# Return Type: INTEGER | BOOLEAN | STRING | DATETIME`r"
    Write-Host "# Variables: KEY,VALUE; KEY,VALUE`r"
    Write-Host "# Platform: LINUX`r"

    Write-Host "Note: The ""Variables:"" metadata in macOS/Linux scripts are optional. Please do not include if not relevant.`r`n"
    Read-Host -Prompt "Press any key to continue"
}

# Clear variables so they don't get reused
Clear-Variable -Name ("PSSensors", "NumSensors", "SmartGroupUUID") -ErrorAction SilentlyContinue

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

# change this to say whether its going to deletes, imports, exports or updates sensors
# also say if its going to assign them
if($Platform){$platformMessage = "$Platform"}else{$platformMessage = "all"}
if($DeleteSensors){
    
    Write-Host "`n`nDeleting all sensors in $WorkspaceONEServer within $OrganizationGroupName. This is destructive and not reversible." -ForegroundColor Red 
    $Response = Read-Host "Are you sure you want to continue?( y / n )"
    Switch ($Response) 
     { 
       Y {$startmsg = "Deleting all sensors in $WorkspaceONEServer within $OrganizationGroupName"; Return $null} 
       N {Write-Host "Exiting Script`n" -ForegroundColor Red; Exit} 
       Default {Write-Host "Exiting Script`n" -ForegroundColor Red; Exit} 
     }
} elseif ($ExportSensors) {
    $startmsg = "Exporting all sensors in $WorkspaceONEServer within $OrganizationGroupName"
} elseif ($UpdateSensors){
    $startmsg = "Updating $platformMessage sensors in $WorkspaceONEServer within $OrganizationGroupName"
} else {
    $startmsg = "Importing $platformMessage sensors into $WorkspaceONEServer within $OrganizationGroupName"
}
Write-Host("*****************************************************************") -ForegroundColor Yellow 
Write-Host($startmsg) -ForegroundColor Yellow 
Write-Host("*****************************************************************") -ForegroundColor Yellow 
                
# Get ogID and UUID from Organizational Group Name
if ($WorkspaceONEOgId -eq $null){
    if($OrganizationGroupName){
        Get-OrganizationIDbyName($OrganizationGroupName)
    }elseif($OrganizationGroupID){
        Get-OrganizationIDbyID($OrganizationGroupID)
    }else{
        Write-Host("Please provide a value for OrganizationGroupName or OrganizationGroupID") -ForegroundColor Yellow 
        Exit
    }
}

# Checking for Supported Console Version
Check-ConsoleVersion

# Downloads Sensors Locally if using the -ExportSensor parameter
if($ExportSensors){
    $download_path = Read-Host -Prompt "Input path to download Sensor samples. Press enter to use the current import_sensor_samples.ps1 directory."
    if ([string]::IsNullOrWhiteSpace($download_path)){
        $download_path = $SensorsDirectory
    }
    Export-Sensors($download_path)
    Write-Host "Sensors have been downloaded to " $download_path -ForegroundColor Yellow
    Write-Host("*****************************************************************") -ForegroundColor Yellow 
    Exit
}

# If DeleteSensors switch is called, then deletes all Sensor samples
if ($DeleteSensors) {
    Delete-Sensors
    Break
}

# Pull in Sensor Samples
$PSSensors = Get-LocalSensors
$NumSensors = $PSSensors.Count - 1
$newSensors = @()

#Get List of existing Scripts
$ExisitingSensors = Get-Sensors
if($ExisitingSensors){
    $Num = $ExisitingSensors.total_results -1
    $CurrentSensors = $ExisitingSensors.result_set
}

# SmartGroupID or SmartGroupName parameter specified. Get SmartGroupUUID for assignment
if($SmartGroupID){
    Get-SmartGroupUUIDbyID -SGID $SmartGroupID
} elseif ($SmartGroupName){
    Get-SmartGroupUUIDbyName -SGName $SmartGroupName -WorkspaceONEOgId $WorkspaceONEOgId
}

do {
    $Sensor = $PSSensors[$NumSensors]
    $SensorName = $sensor.Name.ToLower()
    Write-Host("`nWorking on $SensorName") -ForegroundColor Green
    $showusage = $false

    Clear-Variable -Name ("scriptPlatform", "Description", "Context", "Architecture", "ResponseType", "Variables", "SensortobeAssigned", "SensorAssigned") -ErrorAction SilentlyContinue

    #Get the actual content
    $content = Get-Content -Path $Sensor.FullName

    # Description: Removes Comment # and Quotes
    $d = $content | Select-String -Pattern 'Description: ' -Raw
    if($d){$Description = $d.Substring($d.LastIndexOf('Description: ')+13) -replace '[#]' -replace '"',"" -replace "'",""}else{$showusage = $true}
    # Execution Context: USER, SYSTEM
    $c = $content | Select-String -Pattern 'Execution Context: ' -Raw
    if($c){$Context = $c.Substring(($c.LastIndexOf('Execution Context: ')+19))  -replace '[#]' -replace '"',"" -replace "'",""}else{$showusage = $true}
    # Execution Architecture: EITHER64OR32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY
    $a = $content | Select-String -Pattern 'Execution Architecture: ' -Raw
    if($a){$Architecture = $a.Substring(($a.LastIndexOf('Execution Architecture: ')+24))  -replace '[#]' -replace '"',"" -replace "'",""}else{$showusage = $true}
    # Return Type: INTEGER, BOOLEAN, STRING, DATETIME
    $r = $content | Select-String -Pattern 'Return Type: ' -Raw
    if($r){$ResponseType = $r.Substring(($r.LastIndexOf('Return Type: ')+13))  -replace '[#]' -replace '"',"" -replace "'",""}else{$showusage = $true}
    # Variables: Key, Value; Key, Value
    $v = $content | Select-String -Pattern 'Variables: ' -Raw
    if($v){$Varibles = $v.Substring(($v.LastIndexOf('Variables: ')+8))  -replace '[#]' -replace '"',"" -replace "'",""}else{$showusage = $true}
    # Platform: WIN_RT | APPLE_OSX | LINUX
    $p = $content | Select-String -Pattern 'Platform: ' -Raw
    if($p){$scriptPlatform = $p.Substring(($p.LastIndexOf('Platform: ')+10))  -replace '[#]' -replace '"',"" -replace "'",""}else{$showusage = $true}

    switch ($scriptPlatform) {
        "Windows" { $Platform = "Windows" }
        "macOS" { $Platform = "macOS" }
        "Linux" { $Platform = "Linux" }
        Default { $Platform = $null }
    }

    if(!$showusage){usage -ScriptName $SensorName;$NumScripts--;Continue}

    # Encode Script
    $Data = Get-Content -Path $Sensor.FullName -Encoding UTF8 -Raw
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
    $Script = [Convert]::ToBase64String($Bytes)

    switch -Regex ( $SensorName )
    {
        '^.*\.(ps1)$'
        {
        $query_type = "POWERSHELL"
        $os = "WIN_RT"
        $SensorName = $SensorName.Replace(".ps1","").Replace(" ","_")
        }
        '^.*\.(py)$'
        {
        $query_type = "PYTHON"
        $os = "APPLE_OSX"
        $SensorName = $SensorName.Replace(".py","").Replace(" ","_")
        }
        '^.*\.(zsh)$'
        {
        $query_type = "ZSH"
        $os = "APPLE_OSX"
        $SensorName = $SensorName.Replace(".zsh","").Replace(" ","_")
        }
        '^.*\.(sh)$'
        {
            #macOS and Linux both support BASH shell script
            $ShaBang = $content[0].ToLower()
            switch -Regex ( $ShaBang )
            {
                '^.*(\/bash)$'
                {
                    $query_type = "BASH"
                    if($scriptPlatform -eq "LINUX"){
                        $os = $scriptPlatform
                    }else{
                        $os = "APPLE_OSX"
                    }
                    $SensorName = $SensorName.Replace(".sh","").Replace(" ","_")
                }
                '^.*(\/zsh)$'
                {
                    $query_type = "ZSH"
                    $os = "APPLE_OSX"
                    $SensorName = $SensorName.Replace(".sh","").Replace(".zsh","").Replace(" ","_")
                }
                default
                {
                    $query_type = "BASH"
                    if($scriptPlatform -eq "LINUX"){
                        $os = $scriptPlatform
                    }else{
                        $os = "APPLE_OSX"
                    }                
                    $SensorName = $SensorName.Replace(".sh","").Replace(" ","_")
                }
            }
        }
        default # searches the sha-bang for sensors with no file extension 
        {
            $ShaBang = $content[0].ToLower()
            switch -Regex ( $ShaBang )
            {
                '^.*(\/bash)$'
                {
                    $query_type = "BASH"
                    if($scriptPlatform -eq "LINUX"){
                        $os = $scriptPlatform
                    }else{
                        $os = "APPLE_OSX"
                    }
                    $SensorName = $SensorName.Replace(".sh","").Replace(" ","_")
                }
                '^.*(\/zsh)$'
                {
                    $query_type = "ZSH"
                    $os = "APPLE_OSX"
                    $SensorName = $SensorName.Replace(".sh","").Replace(".zsh","").Replace(" ","_")
                }
                '^.*(\/python)$'
                {
                    $query_type = "PYTHON"
                    $os = "APPLE_OSX"
                    $SensorName = $SensorName.Replace(".py","").Replace(" ","_")
                }
                default
                {
                    $query_type = "BASH"
                    if($scriptPlatform -eq "LINUX"){
                        $os = $scriptPlatform
                    }else{
                        $os = "APPLE_OSX"
                    }
                    $SensorName = $SensorName.Replace(".sh","").Replace(" ","_")
                }
            }
        }
    }
    
    # If sensor already exists & UpdateSensor parameter is provided, then update into the console
    if(($os -eq $Platform) -or (!$Platform)){
        # Check if Sensor Already Exists
        if (Check-Duplicate-Sensor -SensorName $SensorName) {
            if($UpdateSensors){
                Write-Host("Updating exiting sensor $SensorName.") -ForegroundColor Green
                $SensortobeAssigned = $True

                if($os -eq 'WIN_RT'){
                    $SensorUUID=$CurrentSensorUUID
                    Update-Sensors -Description $Description -Context $Context -Architecture $Architecture -SensorName $SensorName -ResponseType $ResponseType -Script $Script -query_type $query_type -os $os -Varibles $Varibles
                }
                elseif(($os -eq 'APPLE_OSX') -or ($os -eq 'LINUX')){
                    $SensorUUID=$CurrentSensorUUID
                    Update-Sensors -Description $Description -Context $Context -SensorName $SensorName -ResponseType $ResponseType -Script $Script -query_type $query_type -os $os -Varibles $Varibles
                }
            } else {
                $SensortobeAssigned = $False
                write-host "Not updating existing sensor." -ForegroundColor Yellow
            }
        } else {
            # Import new Sensor
            $SensortobeAssigned = $True
            if($os -eq 'WIN_RT'){
                $addsensor = Set-Sensors -Description $Description -Context $Context -Architecture $Architecture -SensorName $SensorName -ResponseType $ResponseType -Script $Script -query_type $query_type -os $os -Varibles $Varibles
                $SensorUUID=$addsensor.uuid
            }
            elseif(($os -eq 'APPLE_OSX') -or ($os -eq 'LINUX')){
                $addsensor = Set-Sensors -Description $Description -Context $Context -SensorName $SensorName -ResponseType $ResponseType -Script $Script -query_type $query_type -os $os -Varibles $Varibles
                $SensorUUID=$addsensor.uuid
            }
        }
    } else {
        $SensortobeAssigned = $False
        Write-Host($SensorName + " isn't for " + $Platform + ". Skipping!") -ForegroundColor Yellow
    }

    if($SmartGroupUUID -and $SensortobeAssigned){

        $SensorAssignments = get-SensorAssignments -SensorUUID $SensorUUID
        foreach($assignment in $SensorAssignments){
            if($assignment.smart_group_uuid -eq $SmartGroupUUID){
                $SensorAssigned = $True
                Write-Host "Sensor already assigned to SG: $SmartGroupName" -ForegroundColor Yellow
            } else {
                $SensorAssigned = $False
            }
        }
        if(!$SensorAssigned){
            $sensorAssigned = Assign-Sensors -SensorUUID $SensorUUID
            Write-Host "Assigning Sensor: $SensorName to SG: $SmartGroupName" -ForegroundColor Green 
        }

    }
    
    $NumSensors--
} while (
    $NumSensors -ge 0
)

Write-Host("`n`n*****************************************************************") -ForegroundColor Yellow 
Write-Host("`t`t`t`tProcess Complete") -ForegroundColor Yellow 
Write-Host("`t`t`tPlease review the status messages above") -ForegroundColor Yellow 
Write-Host("*****************************************************************") -ForegroundColor Yellow 