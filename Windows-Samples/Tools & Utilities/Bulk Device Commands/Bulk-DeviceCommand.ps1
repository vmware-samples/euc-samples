<#
.Synopsis
  This Powershell script allows you to issue commands to groups of devices in bulk
   that are available via API but not currently in the console. Commands such 
   as Device Lock or Enterprise Reset can be issued against a targeted group of devices to speed up Admin tasks. 
.DESCRIPTION
   When run, the script will retrieve a list of devices from the provided 
   Smart Group and execute the provided command against those devices.
.EXAMPLE
  .\Bulk-DeviceCommand.ps1 `
    -awServer "https://YourTenant.com" `
    -awTenantAPIKey "YourAPIKey" `
    -awAPIUsername "YourUserName" `
    -awAPIPassword "YourPassword" `
    -smartGroup "Beta Testers" `
    -command "Lock" `
    -Verbose

#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$awServer = "https://YourTenant.com",

    [Parameter(Mandatory=$True)]
    [string]$awTenantAPIKey = "YourAPIKey",

    [Parameter(Mandatory=$True)]
    [string]$awAPIUsername = "YourUserName",

    [Parameter(Mandatory=$True)]
    [string]$awAPIPassword = "YourPassword",

    [Parameter(Mandatory=$True)]
    [string]$smartGroup,

    [Parameter(Mandatory=$True)]
    [string]$command
)

# Global var to see if we are in verbose mode or not - default to false
$global:isVerbose = $false

<#
  This implementation uses Basic authentication.  See "Client side" at https://en.wikipedia.org/wiki/Basic_access_authentication for a description
  of this implementation.
#>
Function Create-BasicAuthHeader {

	Param(
		[Parameter(Mandatory=$True)]
		[string]$username,
		[Parameter(Mandatory=$True)]
		[string]$password
    )

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
        [string]$acceptType
    )

    $header = @{"Authorization" = $authString; "aw-tenant-code" = $tenantCode; "Accept" = $acceptType.ToString(); "Content-Type" = "application/json"}

    Return $header
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

function Write-Log {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$logString
    )

    $logDate = Get-Date -UFormat "%y-%m-%d"
    $dateTime = (Get-Date).toString()
    $logPath = "$($OutputFolder)\Logs"

    if (!(Test-Path -Path $logPath)) {
      New-Item -Path $logPath -ItemType Directory | Out-Null
    }

    $logFile = "$($logPath)\log-$($logDate).txt"
    "$($dateTime) | $($logString)" | Out-File -FilePath $logFile -Append
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

function Get-SmartGroupID {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$smartGroupName,

        [Parameter(Mandatory=$True)]
        $headers,

        [Parameter(Mandatory=$True)]
        $awURL
    )

    Write-Verbose "Searching for $($smartGroupName)'s ID value"

    $smartGroupName = [uri]::EscapeDataString($smartGroupName)
    $url = "$($awURL)/API/mdm/smartgroups/search?name=$($smartGroupName)"
    
    $res = Invoke-AirWatchAPIRequest -awURL $url -headers $headers -Verb GET
    
    $groups = $res.SmartGroups;

    return $groups[0];

}

function Fetch-DeviceList {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$smartGroupID,

        [Parameter(Mandatory=$True)]
        $headers,

        [Parameter(Mandatory=$True)]
        $awURL
    )

    $url = "$($awURL)/API/mdm/smartgroups/$($smartGroupID)/devices"
    
    Write-Verbose "Fetching devices from $($url)"
    $res = Invoke-AirWatchAPIRequest -awURL $url -headers $headers -Verb GET

    return $res.Devices
}

function Invoke-MDMCommand {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$deviceID,

        [Parameter(Mandatory=$True)]
        [string]$command,

        [Parameter(Mandatory=$True)]
        $headers,

        [Parameter(Mandatory=$True)]
        $awURL
    )

    $url = "$($awURL)/API/mdm/devices/$($deviceID)/commands?command=$($command)"

    Write-Host "Executing $($command) on Device ID = $($deviceID)"
    $res = Invoke-AirWatchAPIRequest -awURL $url -headers $headers -Verb POST
}

Function Main {

    # If they passed the verbose arg, set the global var
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
      $global:isVerbose = $true
    }

    # Build API Headers
    $authString = Create-BasicAuthHeader -username $awAPIUsername -password $awAPIPassword
    $headers = Create-Headers -authString $authString -tenantCode $awTenantAPIKey -acceptType "application/json"
    Write-Verbose "Headers :: $($headers)"

    # Check API Version
    $version = Get-AirWatchVersion -headers $headers
    Write-Host "AirWatch Version is $($version)"

    $groupID = Get-SmartGroupID -smartGroupName $smartGroup -headers $headers -awURL $awServer
    
    $groupID = $groupID.SmartGroupID
    Write-Host "Smart Group ID is $($groupID)"

    Write-Host "Retrieving device list for $($smartGroup)"
    
    
    $devices = Fetch-DeviceList -smartGroupID $groupID -headers $headers -awURL $awServer
    
    foreach($device in $devices) {
        Write-Host "Executing $($command) on $($device.Name)"
        try {
            Invoke-MDMCommand -deviceID $device.Id -command $command -headers $headers -awURL $awServer
        } catch {
            Write-Error "Unable to execute $($command) on $($device.Name)"
        }
    }

}

Main
