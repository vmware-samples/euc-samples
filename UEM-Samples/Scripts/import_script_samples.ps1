<# Workspace ONE Script Importer

  .SYNOPSIS
    This Powershell script allows you to automatically import Windows 10 and macOS scripts as Workspace ONE Scripts into the Workspace ONE UEM Console. 
    MUST RUN AS ADMIN
  .NOTES
    Created:   	    January, 2021
    Created by:	    Josue Negron, jnegron@vmware.com
    Contributors:   Chris Halstead, chealstead@vmware.com; Phil Helmling, helmlingp@vmware.com
    Organization:   VMware, Inc.
    Filename:       import_script_samples.ps1
    Updated:        May, 2023, helmlingp@vmware.com
    Github:         https://github.com/vmware-samples/euc-samples/tree/master/UEM-Samples/Scripts

  .DESCRIPTION
    Place this PowerShell script in the same directory of all of your samples (.ps1, .sh, .zsh, .py files) or use the -ScriptsDirectory parameter to 
    specify your directory. This script will parse the sample sensors, check if they already exist, then upload to Workspace ONE UEM via 
    the REST API. You can leverage the optional switch parameters to update the sensors included in the source directory, and assign them to the 
    specified Smart Group. There is also an ability to delete or export all sensors.
    
    For Windows Samples be sure to use the following format when creating new samples so that they are imported correctly:
    # Description: Description
    # Execution Context: System | User
    # Execution Architecture: EITHER64OR32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY
    # Timeout: ## greater than 0
    # Variables: KEY,VALUE; KEY,VALUE
    <YOUR POWERSHELL COMMANDS>

    For macOS/Linux Samples be sure to use the following format when creating new samples so that they are imported correctly:
    <YOUR SCRIPT COMMANDS>
    # Description: Description
    # Execution Context: System | User
    # Execution Architecture: UNKNOWN
    # Timeout: ## greater than 0
    # Variables: KEY,VALUE; KEY,VALUE

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
    VMWARE,INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  .EXAMPLE

    .\import_script_samples.ps1
        -WorkspaceONEServer 'https://as###.awmdm.com'
        -WorkspaceONEAdmin 'administrator'
        -WorkspaceONEAdminPW 'P@ssw0rd'
        -WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E='
        -OrganizationGroupName 'Digital Workspace Tech Zone'
        -SmartGroupName 'All Devices'
        -UpdateScripts
        -TriggerType 'SCHEDULE_AND_EVENT'
        -SCHEDULE 'FOUR_HOURS'
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

    .PARAMETER ScriptsDirectory
    OPTIONAL: The directory your script samples are located, default location is the current PowerShell directory of this script. 

    .PARAMETER SmartGroupID
    OPTIONAL: If provided, imported scripts will be assigned to this Smart Group. Exisiting assignments will be overwritten. 
    If wanting to assign, you are required to provide SmartGroupID or SmartGroupName.

    .PARAMETER SmartGroupName
    OPTIONAL: If provided, imported scripts will be assigned to this Smart Group. Exisiting assignments will be overwritten. 
    If wanting to assign, you are required to provide SmartGroupID or SmartGroupName. This option will prompt to select the correct Smart Group
    if multiple Smart Groups are found with a similar name.

    .PARAMETER DeleteScripts
    OPTIONAL: If enabled, all scripts in your environment will be deleted. This action cannot be undone. Ensure you are targeting the correct Organization Group. 

    .PARAMETER UpdateScripts
    OPTIONAL: If enabled, imported scripts will update matched scripts found in the Workspace ONE UEM Console. 

    .PARAMETER ExportScripts
    OPTIONAL: If enabled, all scripts will be downloaded locally, this is a good option for backuping up scripts before making updates. 

    .PARAMETER Platform
    OPTIONAL: Keep disabled to import all platforms. If enabled, determines what platform's scripts to import. Supported values are "Windows" or "macOS".  

    .PARAMETER TriggerType
    OPTIONAL: Required when using 'SmartGroupID' or 'SmartGroupName' paramaters. When bulk assigning, provide the Trigger Type: 'SCHEDULE', 'EVENT', or 'SCHEDULE_AND_EVENT'

    .PARAMETER SCHEDULE
    OPTIONAL: Required when using 'SCHEDULE' or 'SCHEDULE_AND_EVENT' as TriggerType provide the schedule interval: 'FOUR_HOURS', 'SIX_HOURS', 'EIGHT_HOURS', 'TWELEVE_HOURS', or 'TWENTY_FOUR_HOURS'

    .PARAMETER LOGIN
    OPTIONAL: Required when using 'EVENT' or 'SCHEDULE_AND_EVENT' as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'

    .PARAMETER LOGOUT
    OPTIONAL: Required when using 'EVENT' or 'SCHEDULE_AND_EVENT' as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'

    .PARAMETER STARTUP
    OPTIONAL: Required when using 'EVENT' or 'SCHEDULE_AND_EVENT' as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'

    .PARAMETER RUN_IMMEDIATELY
    OPTIONAL: Required when using 'EVENT' or 'SCHEDULE_AND_EVENT' as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'

    .PARAMETER NETWORK_CHANGE
    OPTIONAL: Required when using 'EVENT' or 'SCHEDULE_AND_EVENT' as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'
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

# Returns the Numerial Organization ID Name & UUID for the Organizational Group Name Provided
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
        #Write-Host("Organization Name for $WorkspaceONEOgId = $OrganizationGroupName with UUID = $WorkspaceONEGroupUUID")
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
    Write-Host("Getting Group UUID from Group Name")
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
        Write-host("Smart Group Name: " + $SGName + " not found. Please check your assignment group name and try again.")
    } elseif ($SGSearchTotal -eq 1){
        $Choice = 0
        #write-host "only one SG found"
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
    $SmartGroupUUID = $getSG.SmartGroupUuid
    return $SmartGroupUUID
}

# Returns Workspace ONE UEM Console Version
Function Check-ConsoleVersion {
    #Write-Host("Checking Console Version") -ForegroundColor Green
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
    Write-Host "Getting List of Scripts in the Console" -ForegroundColor Green
    $endpointURL = $URL + "/mdm/groups/" + $WorkspaceONEGroupUUID + "/scripts?page_size=1000"
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $headerv2
    $Scripts = $webReturn
    if($Scripts){
        Write-Host($Scripts.RecordCount.toString() + " scripts found in console")
    } else {
        Write-Host "No Scripts Found in Console. Let's add some!" -ForegroundColor Yellow
    }
    Return $Scripts
}

# Creates a new Script to the Workspace ONE UEM Console
Function Set-Scripts {
    param (
        [Parameter(Mandatory=$True)]
        [string]$Description,
        [Parameter(Mandatory=$True)]
        [string]$Context,
        [Parameter(Mandatory=$True)]
        [string]$ScriptName,
        [Parameter(Mandatory=$True)]
        [string]$Timeout,
        [Parameter(Mandatory=$True)]
        [string]$Script,
        [Parameter(Mandatory=$True)]
        [string]$Script_Type,
        [Parameter(Mandatory=$True)]
        [string]$os,
        [Parameter(Mandatory=$False)]
        [string]$Architecture,
        [Parameter(Mandatory=$False)]
        [string]$Varibles
    )
    #Write-Host("Creating new Script with name " + $ScriptName)
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
Function Update-Scripts {
    param (
        [Parameter(Mandatory=$True)]
        [string]$Description,
        [Parameter(Mandatory=$True)]
        [string]$Context,
        [Parameter(Mandatory=$True)]
        [string]$ScriptName,
        [Parameter(Mandatory=$True)]
        [string]$Timeout,
        [Parameter(Mandatory=$True)]
        [string]$Script,
        [Parameter(Mandatory=$True)]
        [string]$Script_Type,
        [Parameter(Mandatory=$True)]
        [string]$os,
        [Parameter(Mandatory=$False)]
        [string]$Architecture,
        [Parameter(Mandatory=$False)]
        [string]$Varibles,
        [Parameter(Mandatory=$False)]
        [string]$ScriptUUID
    )

    $endpointURL = $URL + "/mdm/scripts/" + $ScriptUUID
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

# Returns list of SG assignments to a Sensor
function get-ScriptAssignments {
    param (
        [Parameter(Mandatory=$True)]
        [string]$ScriptUUID
    )
    $endpointURL = $URL + "/mdm/scripts/$ScriptUUID/assignments"
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $headerv2
    $assignments = $webReturn.SearchResults.assigned_smart_groups
    return $assignments
}

# Assigns Scripts
Function Assign-Scripts {
    param (
        [Parameter(Mandatory=$True)]
        [string]$ScriptUUID,
        [Parameter(Mandatory=$True)]
        [string]$SmartGroupName,
        [Parameter(Mandatory=$True)]
        [string]$SmartGroupUUID
    )

    $endpointURL = $URL + "/mdm/scripts/$ScriptUUID/updateassignments"
    $EventsBody = @()
    if(!$TriggerType) { 
        $TriggerType = "SCHEDULE"
        if(!$TriggerSchedule) {$TriggerSchedule = "FOUR_HOURS"}
    } elseif ($TriggerType = "SCHEDULE") {
        if(!$TriggerSchedule) {$TriggerSchedule = "FOUR_HOURS"}
    } elseif ($TriggerType = "EVENT") {
        if($LOGIN) {$EventsBody += "LOGIN"}
        if($LOGOUT) {$EventsBody += "LOGOUT"}
        if($STARTUP) {$EventsBody += "STARTUP"}
        if($RUN_IMMEDIATELY) {$EventsBody += "RUN_IMMEDIATELY"}
        if($NETWORK_CHANGE) {$EventsBody += "NETWORK_CHANGE"}
    } elseif ($TriggerType = "SCHEDULE_AND_EVENT") {
        if($TriggerSchedule) { $TriggerSchedule = "FOUR_HOURS" }
        if($LOGIN) {$EventsBody += "LOGIN"}
        if($LOGOUT) {$EventsBody += "LOGOUT"}
        if($STARTUP) {$EventsBody += "STARTUP"}
        if($RUN_IMMEDIATELY) {$EventsBody += "RUN_IMMEDIATELY"}
        if($NETWORK_CHANGE) {$EventsBody += "NETWORK_CHANGE"}
    }

    $SmartGroupBody = @()
    $SmartGroupBody += @{ 
        'smart_group_uuid' = "$SmartGroupUUID";
        'smart_group_name' = "$SmartGroupName"
    }
    


    $assignmentsbody = @()
   
    $assignmentsbody += @{
        "assignment_uuid"         = "00000000-0000-0000-0000-000000000000";
        'name'                    = $SmartGroupName;
        'priority'                = 1;
        'deployment_mode'         = "AUTO";
        'show_in_catalog'         = $false;
        'memberships'             = $SmartGroupBody;
        'script_deployment'       = @{
            'trigger_type'            = $TriggerType;
            'trigger_events'          = $EventsBody;
            'trigger_schedule'        = $TriggerSchedule;
            };
        }
    $body += @{
        "assignments" = $assignmentsbody
    }
    $json = $body | ConvertTo-Json -Depth 100
    $webReturn = Invoke-RestMethod -Method Post -Uri $endpointURL -Headers $header -Body $json
}

# Parse Local PowerShell Files
Function Get-LocalScripts {
    Write-Host("Parsing Local Files for Scripts")
    #$Scripts = Select-String -Path $ScriptsDirectory\* -Pattern 'Execution Context' -Context 10000000 -ErrorAction SilentlyContinue
    $ExcludedcTemplates = "import_script_samples|template*"
    $Scripts = Get-ChildItem -File | Where-Object Name -NotMatch $ExcludedcTemplates
    Write-Host("Found " + $Scripts.Count + " Scripts Samples") -ForegroundColor Green
    Return $Scripts
}

# Check for Duplicates
Function Check-Duplicate-Script($ScriptName) {

    $Duplicate = $False
    DO
    {
        $Result = $CurrentScripts[$Num].Name -eq $ScriptName
        if($Result){
            $Duplicate = $True
            $script:CurrentScriptUUID = $CurrentScripts[$Num].script_uuid
            #$script:CurrentScriptAssignmentCount = $CurrentScripts[$Num].assignment_count
        }
        $Num--
    } while ($Num -ge 0)
    
    Return $Duplicate
}

# Delete A Script
Function Delete-A-Script {
    param (
        [Parameter(Mandatory=$True)]
        [string]$ScriptUUID
    )
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

# Delete all Scripts
Function Delete-Scripts {
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
Function Get-Script {
    param (
        [Parameter(Mandatory=$True)]
        [string]$ScriptUUID
    )
    $endpointURL = $URL + "/mdm/scripts/" + $ScriptUUID
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
        $Script = Get-Script -ScriptUUID $ScriptUUID
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

Function usage {
    param (
        [Parameter(Mandatory=$True)]
        [string]$ScriptName
    )

    Write-Host("*****************************************************************") -ForegroundColor Yellow 
    Write-Host("               $ScriptName Header Missing ") -ForegroundColor Yellow 
    Write-Host("*****************************************************************") -ForegroundColor Yellow 
    Write-Host "`rPlease ensure that $ScriptName script includes the required header so that it can be imported correctly.`r" -ForegroundColor Yellow
    Write-Host "Note: The ""Variables:"" metadata is optional for all platforms. Please do not include if not relevant.`r`n"

    Write-Host "Example Windows Script Header`r" -ForegroundColor Green
    Write-Host "# Description: Description`r"
    Write-Host "# Execution Context: System | User`r"
    Write-Host "# Execution Architecture: EITHER64OR32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY`r"
    Write-Host "# Timeout: ## greater than 0`r"
    Write-Host "# Variables: KEY,VALUE; KEY,VALUE`r"
    Write-Host "<YOUR POWERSHELL COMMANDS>`r`n"

    Write-Host "Example macOS/Linux Script Header`r" -ForegroundColor Green
    Write-Host "<YOUR SCRIPT COMMANDS>`r"
    Write-Host "# Description: Description`r"
    Write-Host "# Execution Context: System | User`r"
    Write-Host "# Execution Architecture: UNKNOWN`r"
    Write-Host "# Timeout: ## greater than 0`r"
    Write-Host "# Variables: KEY,VALUE; KEY,VALUE`r"
    Write-Host "Note: The ""Execution Architecture: UNKNOWN"" metadata is mandatory for macOS/Linux platforms.`r"
    Read-Host -Prompt "Press any key to continue"
}

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

# Construct REST HEADER
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


Write-Host("*****************************************************************") -ForegroundColor Yellow 
Write-Host("               Starting up the Import Process") -ForegroundColor Yellow 
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

# Downloads Scripts Locally if using the -ExportScript parameter
if($ExportScripts){
    $download_path = Read-Host -Prompt "Input path to download Script samples. Press enter to use the current import_script_samples.ps1 directory."
    if ([string]::IsNullOrWhiteSpace($download_path)){
        $download_path = $ScriptsDirectory
    }
    Export-Scripts($download_path)
    Write-Host "Scripts have been downloaded to " $download_path -ForegroundColor Yellow
    Write-Host("*****************************************************************") -ForegroundColor Yellow 
    Exit
}
 
# If DeleteScripts switch is called, then deletes all Script samples
if ($DeleteScripts) {
    Delete-Scripts
    Break
}

Clear-Variable -Name ("PSScripts", "NumScripts") -ErrorAction SilentlyContinue
# Pull in Script Samples
$PSScripts = Get-LocalScripts
$NumScripts = $PSScripts.Count - 1
$newScripts = @()

#Get List of existing Scripts
$ExistingScripts = Get-Scripts
if($ExistingScripts){
    $Num = $ExistingScripts.RecordCount -1
    $CurrentScripts = $ExistingScripts.SearchResults
}

do {
    $Script = $PSScripts[$NumScripts]
    $ScriptName = $Script.Name.ToLower()
    Write-Host("Working on $ScriptName") -ForegroundColor Green
    $usageflag = $false

    #Get the actual content
    $content = Get-Content -Path $Script.FullName

    $d = $content | Select-String -Pattern 'Description: ' -Raw -ErrorAction SilentlyContinue
    if($d){$Description = $d.Substring($d.LastIndexOf('Description: ')+13) -replace '[#]' -replace '"',"" -replace "'",""}else{$usageflag = $true}
    # Execution Context: USER, SYSTEM
    $c = $content | Select-String -Pattern 'Execution Context: ' -Raw -ErrorAction SilentlyContinue
    if($c){$Context = $c.Substring(($c.LastIndexOf('Execution Context: ')+19))  -replace '[#]' -replace '"',"" -replace "'",""}else{$usageflag = $true}
    # Execution Architecture: EITHER64OR32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY
    $a = $content | Select-String -Pattern 'Execution Architecture: ' -Raw -ErrorAction SilentlyContinue
    if($a){$Architecture = $a.Substring(($a.LastIndexOf('Execution Architecture: ')+24))  -replace '[#]' -replace '"',"" -replace "'",""}else{$usageflag = $true}
    # Return Type: INTEGER, BOOLEAN, STRING, DATETIME
    $t = $content | Select-String -Pattern 'Timeout: ' -Raw -ErrorAction SilentlyContinue
    if($t){$Timeout = $t.Substring(($t.LastIndexOf('Timeout: ')+9))  -replace '[#]' -replace '"',"" -replace "'",""}else{$usageflag = $true}
    # Variables: Key, Value; Key, Value
    $v = $content | Select-String -Pattern 'Variables: ' -Raw -ErrorAction SilentlyContinue
    if($v){$Varibles = $v.Substring(($v.LastIndexOf('Variables: ')+11))  -replace '[#]' -replace '"',"" -replace "'",""}
    
    if($usageflag){usage -ScriptName $ScriptName;$NumScripts--;Continue}

    # Encode Script
    $Data = Get-Content -Path $Script.FullName -Encoding UTF8 -Raw
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
    $Script = [Convert]::ToBase64String($Bytes)
    switch -Regex ( $ScriptName )
    {
        '^.*\.(ps1)$'
        {
            $Script_Type = "POWERSHELL"
            $os = "WIN_RT"
            $ScriptName = $ScriptName.Replace(".ps1","").Replace(" ","_")
        }
        '^.*\.(py)$'
        {
            $Script_Type = "PYTHON"
            $os = "APPLE_OSX"
            $ScriptName = $ScriptName.Replace(".py","").Replace(" ","_")
        }
        '^.*\.(zsh)$'
        {
            $Script_Type = "ZSH"
            $os = "APPLE_OSX"
            $ScriptName = $ScriptName.Replace(".zsh","").Replace(" ","_")
        }
        '^.*\.(sh)$'
        {
            $ShaBang = $content[0].ToLower()
            switch -Regex ( $ShaBang )
            {
                '^.*(\/bash)$'
                {
                    $Script_Type = "BASH"
                    $os = "APPLE_OSX"
                    $ScriptName = $ScriptName.Replace(".sh","").Replace(" ","_")
                }
                '^.*(\/zsh)$'
                {
                    $Script_Type = "ZSH"
                    $os = "APPLE_OSX"
                    $ScriptName = $ScriptName.Replace(".sh","").Replace(".zsh","").Replace(" ","_")
                }
                default
                {
                    $Script_Type = "BASH"
                    $os = "APPLE_OSX"
                    $ScriptName = $ScriptName.Replace(".sh","").Replace(" ","_")
                }
            }
        }
        default # searches the sha-bang for scripts with no file extension 
        {
            $ShaBang = $content.ToLower()
            switch -Regex ( $ShaBang )
            {
                '^.*(\/bash)$'
                {
                    $Script_Type = "BASH"
                    $os = "APPLE_OSX"
                    $ScriptName = $ScriptName.Replace(".sh","").Replace(" ","_")
                }
                '^.*(\/zsh)$'
                {
                    $Script_Type = "ZSH"
                    $os = "APPLE_OSX"
                    $ScriptName = $ScriptName.Replace(".sh","").Replace(".zsh","").Replace(" ","_")
                }
                '^.*(\/python)$'
                {
                    $Script_Type = "PYTHON"
                    $os = "APPLE_OSX"
                    $ScriptName = $ScriptName.Replace(".py","").Replace(" ","_")
                }
                default
                {
                    $Script_Type = "BASH"
                    $os = "APPLE_OSX"
                    $ScriptName = $ScriptName.Replace(".sh","").Replace(" ","_")
                }
            }
        }
    }
    
    # Check if Script Already Exists
    if (Check-Duplicate-Script $ScriptName) {
        # If script already exists & UpdateSensor parameter is provided, then update into the console
        $ScripttobeAssigned = $False
        if($UpdateScripts){
            # Check if Script Already Exists
            Write-Host($ScriptName + " already exists in this tenant. Updating the Script in the Console") -ForegroundColor White
            if(!$Platform -or (($Platform -eq 'Windows' -and $OS -eq 'WIN_RT') -or ($Platform -eq 'macOS' -and $OS -eq 'APPLE_OSX'))){
                $ScriptUUID=$CurrentScriptUUID
                Update-Scripts -Description $Description -Context $Context -ScriptName $ScriptName -Timeout $Timeout -Script $Script -Script_Type $Script_Type -OS $OS -Architecture $Architecture -Varibles $Varibles -ScriptUUID $ScriptUUID
                #Add this script to an array to be used to assign to Smart Group
                $newScripts+=$ScriptName -replace " ","_"
            }else{
                Write-Host($ScriptName + " isn't for " + $Platform + ". Skipping!") -ForegroundColor Yellow
            }
        } else {
            write-host "Script is a duplicate and UpdateScript option is not set. Do Nothing." -ForegroundColor Yellow
        }
    } else { 
        # Import new Scripts
        if( !$Platform -or (($Platform -eq 'Windows' -and $OS -eq 'WIN_RT') -or ($Platform -eq 'macOS' -and $OS -eq 'APPLE_OSX'))){
            Set-Scripts -Description $Description -Context $Context -ScriptName $ScriptName -Timeout $Timeout -Script $Script -Script_Type $Script_Type -OS $OS -Architecture $Architecture -Varibles $Varibles
            #Add this script to an array to be used to assign to Smart Group
            $newScripts+=$ScriptName -replace " ","_"
        } else {
            Write-Host($ScriptName + " isn't for " + $Platform + ". Skipping!") -ForegroundColor Yellow
        }
    }
    
    $NumScripts--
} While (
    $NumScripts -ge 0
)

# Assign Scripts to Smart Group if option is set
#Get Smart Group ID and UUID
if(($SmartGroupID -ne 0) -or $SmartGroupName){
    Write-Host("Assigning Scripts to Smart Group $SmartGroupName") -ForegroundColor Green

    if($SmartGroupID){
        Get-SmartGroupUUIDbyID -SGID $SmartGroupID
        #write-host "SmartGroupID function SmartGroupUUID = $SmartGroupUUID"
    }elseif($SmartGroupName){
        $SmartGroupUUID = Get-SmartGroupUUIDbyName -SGName $SmartGroupName -WorkspaceONEOgId $WorkspaceONEOgId
        #write-host "Get-SmartGroupUUIDbyName function"
        #write-host "-SGName $SmartGroupName -WorkspaceONEOgId $WorkspaceONEOgId SmartGroupUUID = $SmartGroupUUID"
    }else{
        Write-Host("Please check your values for SmartGroupID or SmartGroupName") -ForegroundColor Yellow 
        Exit
    }
    if($SmartGroupUUID){
        #Get List of Scripts from the Console as ScriptUUID not provided when creating a Script
        $Scripts=Get-Scripts
        $Num = $Scripts.RecordCount #-1
        $Scripts = $Scripts.SearchResults
        DO
        {
            # iterate through Console scripts and get the name
            $ConsoleScript = $Scripts[$Num].Name -replace " ","_"

            $newscript = (Compare-Object $ConsoleScript $newScripts -IncludeEqual | Where-Object -FilterScript {$_.SideIndicator -eq '=='}).InputObject
            if($newscript){
                #check if assigned
                $CurrentScriptAssignmentCount = $Scripts[$Num].assignment_count
                $ScriptUUID = $Scripts[$Num].script_uuid
                if($CurrentScriptAssignmentCount -gt 0){
                    #check existing assignment
                    $ScriptAssignments = get-ScriptAssignments -ScriptUUID $ScriptUUID
                    foreach($assignment in $ScriptAssignments){
                        if($assignment.smart_group_uuid -eq $SmartGroupUUID){
                            $ScripttobeAssigned = $False
                            write-host "Sensor already assigned to SG: $SmartGroupName"
                        } else {
                            $ScripttobeAssigned = $True
                        }
                    }
                    if($ScripttobeAssigned){
                        Assign-Scripts -ScriptUUID $ScriptUUID -SmartGroupName $SmartGroupName -SmartGroupUUID $SmartGroupUUID
                        write-host "Assigned Script: "$Scripts[$Num].Name" to SG: $SmartGroupName"
                    }
                } else {
                    Assign-Scripts -ScriptUUID $ScriptUUID -SmartGroupName $SmartGroupName -SmartGroupUUID $SmartGroupUUID
                    write-host "Assigned Script: "$Scripts[$Num].Name" to SG: $SmartGroupName"
                }

            }
            $Num--
        } while ($Num -ge 0)
    }
}

Write-Host("*****************************************************************") -ForegroundColor Yellow 
Write-Host("                    Import Process Complete") -ForegroundColor Yellow 
Write-Host("             Please review the status messages above") -ForegroundColor Yellow 
Write-Host("*****************************************************************") -ForegroundColor Yellow 