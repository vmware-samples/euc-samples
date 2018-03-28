<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False)]
    [string]$awServer = "https://mondecorp.ssdevrd.com",

    [Parameter(Mandatory=$False)]
    [string]$awTenantAPIKey = "iVvGQnSXpX3eliczZPaIlC8hCe5Q/kw22K3glhE+g/g=",

    [Parameter(Mandatory=$False)]
    [string]$awAPIUsername = "mondecorp\tkent",

    [Parameter(Mandatory=$False)]
    [string]$awAPIPassword = "Passw0rd1"
)

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


    $header = @{"Authorization" = $authString; "aw-tenant-code" = $tenantCode; "Accept" = $acceptType.ToString()}

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

    if(!(Test-Path -Path $logPath)) { New-Item -Path $logPath -ItemType Directory | Out-Null }

    $logFile = "$($logPath)\log-$($logDate).txt"
    "$($dateTime) | $($logString)" | Out-File -FilePath $logFile -Append
}

Function Get-CSVFilePath {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $FileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $FileDialog.InitialDirectory = $env:HOMEPATH
    $FileDialog.Filter = "CSV Files (*.csv)|*.csv"
    $FileDialog.ShowDialog() | Out-Null
    $FileDialog.FileName
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

    $response = Invoke-RestMethod -Method $Verb -Uri $awURL -Headers $headers -Verbose

    Return $response
}

Function Get-DeviceID {
    [CmdletBinding()]
    Param
    (
        # Headers for API Call
        [Parameter(Mandatory=$True)]
        [hashtable]
        $headers,

        # Device ID in AirWatch
        [Parameter(Mandatory=$True)]
        [string]
        $serialNumber
    )

    $endpointURL = "$($awServer)/api/mdm/devices?searchby=serialnumber&id=$($serialNumber)"

    $response = Invoke-AirWatchAPIRequest -headers $headers -Verb GET -awURL $endpointURL
    $id = $response.Id.Value

    Return $id
}

Function Verify-UserChange {
[CmdletBinding()]
    Param
    (
        # Headers for API Call
        [Parameter(Mandatory=$True)]
        [hashtable]
        $headers,

        # Device ID in AirWatch
        [Parameter(Mandatory=$True)]
        [string]
        $serialNumber
    )

    $endpointURL = "$($awServer)/api/mdm/devices?searchby=serialnumber&id=$($serialNumber)"

    $response = Invoke-AirWatchAPIRequest -headers $headers -Verb GET -awURL $endpointURL
    $user = $response.UserName

    Return $user
}

Function Get-EnrollmentUserID {
    [CmdletBinding()]
    Param
    (
        # Headers for API Call
        [Parameter(Mandatory=$True)]
        [hashtable]
        $headers,

        # Username in AirWatch
        [Parameter(Mandatory=$True)]
        [string]
        $enrollmentUser
    )

    $endpointURL = "$($awServer)/api/system/users/search?username=$($enrollmentUser)"
        
    $response = Invoke-AirWatchAPIRequest -headers $headers -Verb GET -awURL $endpointURL

    #Search for user in returned Array
    Foreach($User in $response.Users) {
        if($user.UserName -eq $enrollmentUser) {
            Return $User.Id.Value
        }
    }

    Return -1
}


Function Change-EnrollmentUser
{
    [CmdletBinding()]
    Param
    (
        # Headers for API Call
        [Parameter(Mandatory=$True)]
        [hashtable]
        $headers,

        # Device ID in AirWatch
        [Parameter(Mandatory=$True)]
        [int]
        $deviceID,

        # Enrollment User ID in AirWatch
        [Parameter(Mandatory=$True)]
        [int]
        $userID
    )

    $endpointURL = "$($awServer)/api/mdm/devices/$($deviceID)/enrollmentuser/$($userID)"

    #Update headers to include version
    $headers["Accept"] = "application/json;version=2"

    $response = Invoke-AirwatchAPIRequest -headers $headers -Verb PATCH -awURL $endpointURL

    Return $response
}



Function Main {
    
    
    # Build API Headers
    $authString = Create-BasicAuthHeader -username $awAPIUsername -password $awAPIPassword
    $headers = Create-Headers -authString $authString -tenantCode $awTenantAPIKey -acceptType "application/json"
    Write-Verbose "Headers :: $($headers)"

    # Check API Version
    $version = Get-AirWatchVersion -headers $headers
    Write-Host "AirWatch Version is $($version)"

    # Fetch Mapping Info
    Write-Host "Prompting User for Mapping CSV"
    $csv = Get-CSVFilePath
    $DeviceMapping = Import-Csv -Path $csv

    Write-Host "Processing $($DeviceMapping.count) records"

    Foreach($Device in $DeviceMapping) {
        # Get Device ID
        Write-Host "Fetching Device ID from AirWatch for $($Device.Username)"
        $deviceID = Get-DeviceID -headers $headers -serialNumber $Device.SerialNumber
        Write-Host "Device ID is $($deviceID)"
        
        # Get Enrollment USer ID
        Write-Host "Fetching Enrollment User ID from AirWatch"
        $userID = Get-EnrollmentUserID -headers $headers -enrollmentUser $Device.UserName
        Write-Host "User ID is $($userID)"

        if($deviceID -ne $null -and $userID -ne -1) {
            # Make Switch
            Write-Host "Switching device to Enrollment user"
            $response = Change-EnrollmentUser -headers $headers -deviceID $deviceID -userID $userID
            
            # Confirm Switch
            $serverUser = Verify-UserChange -headers $headers -serialNumber $Device.SerialNumber

            if($serverUser -eq $Device.UserName) {
                Write-Host "$($Device.UserName) is now associated with $($Device.SerialNumber)"
            } else {
                Write-Host "Mapping failed for $($Device.UserName)" -ForegroundColor Red
            }
        }
        
        
        
    }

}

Main