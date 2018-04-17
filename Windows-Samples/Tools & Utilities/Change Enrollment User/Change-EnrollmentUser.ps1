<#
.Synopsis
  This Powershell script allows you to make a server side change to a device record in AirWatch.
  This script changes the record in AirWatch from the Staging User to the desired End User.
  This script can be used to make server side management of devices easier if devices have been
  enrolled to one user.
.DESCRIPTION
   When run, if command line parameters are not provided, this script will prompt you to select a
   csv file that contains Device Serial number mapping to desired End User.
.EXAMPLE
  .\Change-EnrollmentUser.ps1 `
    -awServer "https://YourTenant.com" `
    -awTenantAPIKey "YourAPIKey" `
    -awAPIUsername "YourUserName" `
    -awAPIPassword "YourPassword" `
    -Verbose

.EXAMPLE
  .\Change-EnrollmentUser.ps1 `
    -awServer "https://YourTenant.com" `
    -awTenantAPIKey "YourAPIKey" `
    -awAPIUsername "YourUserName" `
    -awAPIPassword "YourPassword" `
    -csvFile ".\Template.csv"
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False)]
    [string]$awServer = "https://YourTenant.com",

    [Parameter(Mandatory=$False)]
    [string]$awTenantAPIKey = "YourAPIKey",

    [Parameter(Mandatory=$False)]
    [string]$awAPIUsername = "YourUserName",

    [Parameter(Mandatory=$False)]
    [string]$awAPIPassword = "YourPassword",

    [Parameter(Mandatory=$False)]
    [string]$csvFile,

    [Parameter(Mandatory=$False)]
    [string]$serialNum,

    [Parameter(Mandatory=$False)]
    [string]$uName
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

    if (!(Test-Path -Path $logPath)) {
      New-Item -Path $logPath -ItemType Directory | Out-Null
    }

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

    # If we are in verbose mode
    if ($global:isVerbose) {
        $response = Invoke-RestMethod -Method $Verb -Uri $awURL -Headers $headers -Verbose
    }
    else {
        $response = Invoke-RestMethod -Method $Verb -Uri $awURL -Headers $headers
    }

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

    # If they passed in the optional serial number and user name args
    if ($serialNum -And $uName) {
      # Manually create the custom object
      # This is doing the same thing that Import-Csv does
      $tempObject = New-Object PSCustomObject
      $tempObject | Add-Member -type NoteProperty -name SerialNumber -Value $serialNum
      $tempObject | Add-Member -type NoteProperty -name Username -Value $uName
      # Manually create the DeviceMapping array with our object
      $DeviceMapping = @($tempObject)
    }
    # They did not pass both args, prompt for the csv
    else {
      # If they did not pass in the CSV file, prompt for them to select it
      if (!$csvFile) {
        Write-Host "Prompting User for Mapping CSV"
        $csvFile = Get-CSVFilePath
        # Make sure they selected a CSV File
        if (!$csvFile) {
          Write-Host "No CSV file was selected, cannot continue" -ForegroundColor Red
          exit
        }
      }
      # Process the CSV file (provided via command line or selected)
      $DeviceMapping = Import-Csv -Path $csvFile
    }

    Write-Host "Processing $($DeviceMapping.count) records"

    Foreach($Device in $DeviceMapping) {
        

        # Get Device ID
        Write-Host "Fetching Device ID from AirWatch for $($Device.SerialNumber)"
        $deviceID = Get-DeviceID -headers $headers -serialNumber $Device.SerialNumber
        Write-Host "Device ID is $($deviceID)"

        # If we don't have a device ID, no need to continue processing
        if (!$deviceID) {
          Write-Host "Device '$($Device.SerialNumber)' was not found, cannot process" -ForegroundColor Red
          continue
        }

        # Get Enrollment User ID
        Write-Host "Fetching Enrollment User ID from AirWatch for $($Device.UserName)"
        $userID = Get-EnrollmentUserID -headers $headers -enrollmentUser $Device.UserName
        Write-Host "User ID is $($userID)"

        # If we don't have a valid user ID, display an error
        if ($userID -eq -1) {
          Write-Host "User '$($Device.UserName)' was not found" -ForegroundColor Red
        }

        if ($deviceID -ne $null -and $userID -ne -1) {
            # Make Switch
            Write-Host "Switching device to Enrollment user"
            $response = Change-EnrollmentUser -headers $headers -deviceID $deviceID -userID $userID

            # Confirm Switch
            $serverUser = Verify-UserChange -headers $headers -serialNumber $Device.SerialNumber

            if ($serverUser -eq $Device.UserName) {
                Write-Host "$($Device.UserName) is now associated with $($Device.SerialNumber)"
            }
            else {
                Write-Host "Mapping failed for $($Device.UserName)" -ForegroundColor Red
            }

            #Update headers to remove version from previous device migrations
            $headers["Accept"] = "application/json;"
        }
    }
}

Main
