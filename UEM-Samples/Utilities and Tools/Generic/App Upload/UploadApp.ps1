<#
.SYNOPSIS
  This script connects to your VMware Workspace ONE UEM environment and will upload an application to the server and organization group specified. It is leveraging
  the UploadChunk api to handle larger applications. Starter app templates are provided for Windows 10.
.NOTES
  Version:       	 		1.0
  Author:        		 	Mike Nelson
  Initial Creation Date: 	June 23, 2021
.CHANGELOG
1.0 - Initial version, June 2020
1.1 - App Icon and IconBlobUuId metadata supported for local and remote icon use cases
#>


# Variables
$UserName = 'API USERNAME'
$Password = 'API PASSWORD'
$ApiKey = 'API KEY'
$OrgGroupId = 0
$ServerURL = 'API URL'
$AppFilePath = 'APP FILE PATH'
$AppMetaDataFilePath = 'PATH TO JSON FILE'

# To upload an app icon, either populate:
#   1. $AppIconFilePath with a local image file OR 
#   2. $AppIconFileLink with a remote image file
#       ** When using $AppIconFileLink, the Username and Password fields are only required if the remote file requires authentication to access
$AppIconFilePath = '' 
$AppIconFileLink = ''
$AppIconFileLinkUsername = ''
$AppIconFileLinkPassword = ''

# Set to 20 MB - 100 MB is the max recommended. For slower connections set to lower settings like 5MB
$ChunkSize = 20 * 1024 * 1024

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
  Calls the POST /api/mam/blobs/uploadblob API to upload a local or remote image file which will provide the app icon
  for the SaveApp function to use
#>
Function UploadBlob {
  Param(
    [Parameter(Mandatory=$True)]
    [string]$serverURL,
    [Parameter(Mandatory=$True)]
    $headers,
    [Parameter(Mandatory=$True)]
    [object]$body,
    [Parameter(Mandatory=$False)]
    [Hashtable]$parameters
  )

  $uploadBlobURL = $serverURL + "/api/mam/blobs/uploadblob" + $(FormatApiParameters($parameters));
  Write-Host "uploadBlobURL: $uploadBlobURL"
  $headers.Accept = "application/octet-stream"
  $response = Invoke-RestMethod -Method "POST" -Uri $uploadBlobURL -Headers $headers -Body $body -ContentType 'application/json'
  return $response
}

<#
  Calls the POST /api/mam/apps/internal/uploadchunk API to upload an application in chunks to the UEM server
#>
Function UploadChunk {
    Param(
		[Parameter(Mandatory=$True)]
		[string]$serverURL,
		[Parameter(Mandatory=$True)]
		$headers,
		[Parameter(Mandatory=$True)]
    [string]$body
    )
    
    $ChunkURL = $serverURL + "/api/mam/apps/internal/uploadchunk"
    $response = Invoke-RestMethod -Method "POST" -Uri $ChunkURL -Headers $headers -Body $body -ContentType 'application/json'
    return $response
}

<#
  Calls the POST /api/v1/mam/apps/internal/begininstall API to save an application in UEM, making it available in the UEM adminsitrator console
#>
Function SaveApp {
    Param(
		[Parameter(Mandatory=$True)]
		[String] $Server,
		[Parameter(Mandatory=$True)]
		$headers,
		[Parameter(Mandatory=$True)]
		$appDetails
	)

	$url = "$Server/api/v1/mam/apps/internal/begininstall"

  try {
      $response = Invoke-RestMethod -Method Post -Uri $url.ToString() -Headers $headers -Body $appDetails
  } catch {
        Write-Verbose -Message "Save app failed :: $PSItem"
  }
  Write-Verbose "Response 'Save App' :: $response"
	Return $response
}

<# 
  Helper method to construct API URL parameters from a Hashtable of properties and values
#>
Function FormatApiParameters {
  Param(
    [Parameter(Mandatory=$True)]
    [Hashtable]$parameters
  )

  $str = ""
  $num = 0

  if ($parameters.Count -ge 1) {
    $str += "?"
    foreach ($kvp in $parameters.GetEnumerator()) {
      $str += "$($kvp.Name)=$($kvp.Value)"
      if ($num -lt $parameters.Count - 1) {
        $str += "&"
      }
      $num++
    }
  }
  
  return $str
}

######################
#### Main Process ####
######################

# API Setup
$AuthString = Create-BasicAuthHeader -username $UserName -password $Password
$Headers = Create-Headers -authString $AuthString -tenantCode $ApiKey

# App Icon Setup
$AppIconBlobUUID = ""

# If the $AppIconFilePath is populated, attempt to upload the specified local icon file for use as an app icon in UEM
if ($AppIconFilePath) {
  Write-Host "Prepparing local app icon file for upload"

  # Retrieve the binary (bytearray) of the target local file
  $iconTotalSize = (Get-Item -Path $AppIconFilePath).Length
  $iconFileStream = [System.IO.File]::OpenRead($AppIconFilePath)
  $iconByteArray = New-Object byte[] $iconTotalSize;
  $iconBytes = $iconFileStream.Read($iconByteArray, 0, $iconTotalSize);

  # Retrieve the file name from the file path
  $iconFileName = Split-Path $AppIconFilePath -Leaf
    
  try {
    # Call the uploadblob API and pass the file binary (bytearray) for the body and format the API parameters
    # as '?filename={name}&organizationgroupid={id}
    Write-Host "Uploading $iconFileName (size: $iconTotalSize bytes) for app icon"
    $uploadBlobResponse = UploadBlob -serverURL $ServerURL -headers $Headers -body $iconByteArray -parameters @{
      filename = $iconFileName
      organizationgroupid = $OrgGroupId
    }
    Write-Host "Upload Blob for app icon response: $uploadBlobResponse"

    # Set the $AppIconBlobUUID from the Blob UUID received from the upload response, used later to specify the icon for the uploaded app
    $AppIconBlobUUID = $uploadBlobResponse.uuid
  } catch {
    Write-Error "Script Error"
    Write-Error $_   
  }
}
# If the $AppIconFileLink is populated instead, attempt to upload the specified remote icon file for use as an app icon in UEM
elseif ($AppIconFileLink) {
  Write-Host "Prepparing remote app icon file for upload"
  
  # Call the uploadblob API and specify that the icon is remote by including the following API parameters:
  # '?filename={name}&downloadfilefromlink=true&fileLink={fileURI}&accessVia=Direct
  # If downloading content through a Content Gateway, you will also need to specify:
  # accessVia = 'EIS' and contentGatewayId = the Content Gateway ID that is serving the targeted content URL
  $iconFileName = Split-Path $AppIconFileLink -Leaf
  $parameters = @{
    filename = $iconFileName
    downloadfilefromlink = $true
    fileLink = $AppIconFileLink
    accessVia = 'Direct'
  }

  # If a username and password are required to access the remote image, append them to our API parameters
  if ($AppIconFileLinkUsername) {
    $parameters.Add("username", $AppIconFileLinkUsername)
  }
  if ($AppIconFileLinkPassword) {
    $parameters.Add("password", $AppIconFileLinkPassword)
  }

  try {
    # Call the uploadblob API and pass the necessary parameters to use the remote image file as the app icon blob.
    # When uploading remote images, the body of the request is empty.
    Write-Host "Uploading $AppIconFileLink for app icon"
    $uploadBlobResponse = UploadBlob -serverURL $ServerURL -headers $Headers -body '' -parameters $parameters
    Write-Host "Upload Blob for app icon response: $uploadBlobResponse"

    # Set the $AppIconBlobUUID from the Blob UUID received from the upload response, used later to specify the icon for the uploaded app
    $AppIconBlobUUID = $uploadBlobResponse.uuid
  }
  catch {
    Write-Error "Script Error"
    Write-Error $_   
  }
}

# App Setup
$TotalAppSize = (Get-Item -Path $AppFilePath).Length
$ChunkSequenceNumber = 1 # Sequence is indexed at 1
$TransactionID = ""   #empty string for first upload

# Break app file into chunks
$fileStream = [System.IO.File]::OpenRead($AppFilePath)
$chunk = New-Object byte[] $ChunkSize
$chunksUploaded = 0;

# Read the file in $ChunkSize increments, calling the UploadChunk API to upload portions of the application in each request
# until the entire file has been uploaded and associated by incrementing the $ChunkSequenceNumber
Write-Host "Starting to upload app chunks, depending on app size this may take some time"
while($chunksRead = $fileStream.Read($chunk, 0, $ChunkSize)) {
    #Prepare chunk for upload
    $currentSize = $chunk.Length
    $b64Chunk = [System.Convert]::ToBase64String($chunk)
    
    $body = @{
        TransactionId = $TransactionID
        ChunkData = $b64Chunk
        ChunkSequenceNumber = $ChunkSequenceNumber
        TotalApplicationSize = $TotalAppSize
        ChunkSize = $currentSize
    }

    $body = $body | ConvertTo-Json
    
    # Upload file chunk
    try {
        $chunkRes = UploadChunk -serverURL $ServerURL -headers $Headers -body $body
        Write-Host $chunkRes
        $TransactionID = $chunkRes.TranscationId
    
        # Update on successful upload
        $chunksUploaded += $chunksRead
        $ChunkSequenceNumber++
        $currentStatusMessage = ("Uploaded {0} MB" -f ($chunksUploaded / 1MB))
        Write-Host $currentStatusMessage
    } catch {
        Write-Error "Script Error"
        Write-Error $_   
    }
}

Write-Host "Finished Uploading app chunks"

# Take last transaction id and pass into app json
Write-Host "Final chunk transaction id is $TransactionID"
Write-Host "Updating App meta data with chunk transcation id";
$AppMetaData = Get-Content -Path $AppMetaDataFilePath
$AppMetaData = $AppMetaData | ConvertFrom-Json
$AppMetaData | Add-Member -Name "TransactionId" -Value $TransactionID -MemberType NoteProperty

# Update hte AppMetaData by specifying the Filename, LocationGroupID, and the IconBlobUuid to indicate which icon the app uses (if provided)
$FileName = Split-Path $AppFilePath -Leaf
$AppMetaData.FileName = $FileName
$AppMetaData.LocationGroupId = $OrgGroupId
$AppMetadata.IconBlobUuId = $AppIconBlobUUID

# Remove blob id from object
$AppMetaData.PsObject.Properties.Remove('BlobId')

# Convert the AppMetaData object to JSON to provide to the SaveApp API call body
$AppJson = $AppMetaData | ConvertTo-Json -Depth 10

try {
    # Call the SaveApp API with the app metadata formatted as JSON to save the app to UEM and make it available in the UEM administration console
    Write-Host "Saving app in Workspace ONE UEM...this may take a few minutes"
    $saveRes = SaveApp -Server $ServerURL -headers $Headers -appDetails $AppJson
    Write-Host "$($saveRes.ApplicationName) Uploaded Succesfully"
} catch {
    Write-Error $_
}

