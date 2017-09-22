<#
  This implementation uses Basic authentication.  See "Client side" at https://en.wikipedia.org/wiki/Basic_access_authentication for a description
  of this implementation.
#>
Function Create-BasicAuthHeader {

	Param(
		[Parameter(Mandatory=$True)]
		[string]$username,
		[Parameter(Mandatory=$True)]
		[string]$password)

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
		[string]$acceptType, 
		[Parameter(Mandatory=$True)]
		[string]$contentType)

    $header = @{"Authorization" = $authString; "aw-tenant-code" = $tenantCode; "Accept" = $acceptType; "Content-Type" = $contentType}
     
    Return $header
}

<#
    This Function uploads the app file to the AirWatch server
#>
Function Upload-Blob {
  Param(
	  [Parameter(Mandatory=$True)]
	  [String] $airwatchServer,
	  [Parameter(Mandatory=$True)]
      [String] $filename,
	  [Parameter(Mandatory=$True)]
      [String] $filePath,
	  [Parameter(Mandatory=$True)]
      [String] $groupID,
	  [Parameter(Mandatory=$True)]
      [hashtable] $headers
  )

#$networkFilePath = "Microsoft.Powershell.Core\FileSystem::" + $awProperties.FilePath ***Passing as a param to function to limit work

  $url = Create-BlobURL -baseURL $airwatchServer -filename $filename -groupID $groupID

  $response = Invoke-RestMethod -Method Post -Uri $url.ToString() -Headers $headers -InFile $filePath

  Return $response
}

<# 
  Creates the url for the blob upload
#>
Function Create-BlobURL {
    Param(
		[Parameter(Mandatory=$True)]
		[String] $baseURL,
		[Parameter(Mandatory=$True)]
        [String] $filename,
		[Parameter(Mandatory=$True)]
        [String] $groupID
	)
    $url = "$baseURL/api/mam/blobs/uploadblob?filename=$filename&organizationgroupid=$groupID"

    Return $url
}

Function Save-App {
	Param(
		[Parameter(Mandatory=$True)]
		[String] $awServer,
		[Parameter(Mandatory=$True)]
		[hashtable] $headers,
		[Parameter(Mandatory=$True)]
		$appDetails
	)

	$url = "$awServer/api/v1/mam/apps/internal/begininstall"

	$response = Invoke-RestMethod -Method Post -Uri $url.ToString() -Headers $headers -Body $appDetails

	Return $response
}