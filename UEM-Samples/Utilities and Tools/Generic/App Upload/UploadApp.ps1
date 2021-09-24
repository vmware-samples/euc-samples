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
#>


# Variables
$UserName = 'API USERNAME'
$Password = 'API PASSWORD';
$ApiKey = 'API KEY'
$OrgGroupId = 0
$ServerURL = 'API URL'
$AppFilePath = 'APP FILE PATH'
$AppMetaDataFilePath = 'PATH TO JSON FILE'

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


#Main Process

# Setup
$TotalAppSize = (Get-Item -Path $AppFilePath).Length
$ChunkSequenceNumber = 1 # Sequence is indexed at 1
$TransactionID = ""   #empty string for first upload
$AuthString = Create-BasicAuthHeader -username $UserName -password $Password
$Headers = Create-Headers -authString $AuthString -tenantCode $ApiKey

# Break file into chunks
$fileStream = [System.IO.File]::OpenRead($AppFilePath)
$chunk = New-Object byte[] $ChunkSize

$chunksUploaded = 0;

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
Write-Host "Final chunk transaction id is " + $TransactionID

Write-Host "Updating App meta data with chunk transcation id";
$AppMetaData = Get-Content -Path $AppMetaDataFilePath

$AppMetaData = $AppMetaData | ConvertFrom-Json
$AppMetaData | Add-Member -Name "TransactionId" -Value $TransactionID -MemberType NoteProperty

$FileName = Split-Path $AppFilePath -Leaf
$AppMetaData.FileName = $FileName

$AppMetaData.LocationGroupId = $OrgGroupId

# Remove blob id from object
$AppMetaData.PsObject.Properties.Remove('BlobId')

$AppJson = $AppMetaData | ConvertTo-Json -Depth 10

try {
    Write-Host "Saving app in Workspace ONE UEM...this may take a few minutes"
    $saveRes = SaveApp -Server $ServerURL -headers $Headers -appDetails $AppJson
    Write-Host "$($saveRes.ApplicationName) Uploaded Succesfully"
} catch {
    Write-Error $_
}

