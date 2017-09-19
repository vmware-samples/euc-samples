<#
  This implementation uses Basic authentication.  See "Client side" at https://en.wikipedia.org/wiki/Basic_access_authentication for a description
  of this implementation.
#>
Function Create-BasicAuthHeader {

	Param([string]$username, [string]$password)

	$combined = $username + ":" + $password
	$encoding = [System.Text.Encoding]::ASCII.GetBytes($combined)
	$encodedString = [Convert]::ToBase64String($encoding)

	Return "Basic " + $encodedString
}

<#
  This method builds the headers for the REST API calls being made to the AirWatch Server.
#>
Function Create-Headers {

    Param([string]$authString, [string]$tenantCode, [string]$acceptType, [string]$contentType)

    $header = @{"Authorization" = $authString; "aw-tenant-code" = $tenantCode; "Accept" = $acceptType; "Content-Type" = $contentType}
     
    Return $header
}

<#
    This Function uploads the app file to the AirWatch server
#>
Function Upload-Blob {
  Param([String] $airwatchServer,
        [String] $filename,
        [String] $filePath,
        [String] $groupID,
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
    Param([String] $baseURL,
          [String] $filename,
          [String] $groupID
          )
    $url = "$baseURL/api/mam/blobs/uploadblob?filename=$filename&organizationgroupid=$groupID"

    Return $url
}