<#
.SYNOPSIS
  This script connects to your VMware Workspace ONE UEM environment and queries all device records for the provided organization group
  id using the GET /api/mdm/devices/extensivesearch API. This example provides an overview of how to use recursion to query all records
  with APIs that require pagination.
.NOTES
  Version:       	 		1.0
  Author:        		 	Justin Sheets
  Initial Creation Date: 	January 27, 2022
.CHANGELOG
  1.0 - Initial version, January 2022
#>

# Variables
$UserName = 'API USERNAME'
$Password = 'API PASSWORD';
$ApiKey = 'API KEY'
$OrgGroupId = 0
$ServerURL = 'API URL'

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
		[string]$tenantCode
    )

    $header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $header.Add("Authorization", $authString)
    $header.Add("aw-tenant-code", $tenantCode)
    $header.Add("Accept", "application/json")
    $header.Add("Content-Type", "application/json")
    Return $header
}

<#
    Recursive function that calls GET/api/mdm/devices/extensivesearch with a defined page and pagesize. Will recursively 
    call itself until the final required page is called, which is calculated by the total property in the response divided 
    by the provided page size.
#>
Function QueryDevicesExtensiveSearch {
    Param(
		[Parameter(Mandatory=$True)]
		$headers,
        [Parameter(Mandatory=$True)][AllowEmptyCollection()]
		[array]$records,
		[Parameter(Mandatory=$True)]
        [int]$page,
        [Parameter(Mandatory=$True)]
        [int]$pageSize
    )
    
    $apiUrl = $ServerURL + "/api/mdm/devices/extensivesearch?page=$page&pagesize=$pagesize"
    Write-Host "Query Devices API | page: $page, pagesize: $pagesize, record count: $($records.Count)"
    $response = Invoke-RestMethod -Method "GET" -Uri $apiUrl -Headers $headers

    try {
        $total = $response.total
        $records = $records + $response.Devices
        $lastPage = [Math]::Ceiling($total / $pageSize) - 1
        
        if ($page -ge $lastPage) {
            Write-Host "page ($page) is >= lastPage ($lastPage) - finished! Returning $($records.Count) records"
            return $records
        }
        else {
            Write-Host "page ($page) is < lastPage ($lastPage), increment page and query next data set"
            $page += 1
            return QueryDevicesExtensiveSearch -headers $headers -records $records -page $page -pageSize $pagesize
        }
    }
    catch {
        Write-Error "Script Error"
        Write-Error $_
    }
    
    return $records
}

# Main Process
# Setup
$AuthString = Create-BasicAuthHeader -username $UserName -password $Password
$Headers = Create-Headers -authString $AuthString -tenantCode $ApiKey

# Variables
$page = 0           # page var that can be incremented between calls
$pagesize = 500     # amount of records per page queried (don't exceed 1,000 for SaaS)

# Call QueryDevicesExtensiveSearch with an empty record set. The method will recursively call itself until all pages
# have been successfully queried
Write-Host "Querying device records..."
$devicesRecords = QueryDevicesExtensiveSearch -headers $headers -records @() -page $page -pageSize $pagesize

# Output the final device count
Write-Host "Paginated queries completed, total number of device records = $($devicesRecords.Count)"