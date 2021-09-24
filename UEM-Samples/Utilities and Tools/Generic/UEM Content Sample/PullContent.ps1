$runParams = Get-Content -Raw -Path "./RunParams.json" | ConvertFrom-Json

Function Main {
    # Need to build the REST API headers.  These are used for every call.
    $headers = Build_Headers

    # Need the OG name and ID for the calls to get the content listing.  Write them
    # out for some feedback about what is going on.
    $ogInfo = Get_OG_Name $headers

    # The default page size is 50 items.  This is the loop that handles getting multiple
    # pages.
    $counter = 0
    $pageURL = "FirstPage"
    do {
        $pageURL = Get-UEM-Content $headers $ogInfo.OGName $ogInfo.OGId $pageURL
    }
    while ($pageURL -ne "End")
}

Function Build_Headers {

    # Build the REST Basic Auth Username.
    $serverName = $runParams.UEMConsole
    $concateUserInfo = $runParams.UEMUsername + ":" + $runParams.UEMPassword
    $encoding = [System.Text.Encoding]::ASCII.GetBytes($concateUserInfo)
    $encodedUserName = [Convert]::ToBase64String($encoding)
    $encodedUserName = "Basic " + $encodedUserName
    $restAPIKey = $runParams.UEMRESTAPIKey
    $contentType = "application/json"
    $headers = @{"Authorization" = $encodedUserName; "aw-tenant-code" = $restAPIKey; "Accept" = $contentType; "Content-Type" = $contentType}
    return $headers
}

Function Get_OG_Name {

    Param ([object]$headers)

    $uemHost = $runParams.UEMConsole
    $endpointURI = "$uemHost/API/system/groups/search"
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURI -Headers $headers
    
    $ogName = ""
    $ogID = 0
    foreach ($currentOG in $webReturn.LocationGroups) {
        if ($currentOG.LocationGroupType -eq "Customer") {
            $ogName = $currentOG.Name
            $ogID = $currentOG.Id.Value
        }
    }

    $ogInfo = [PSCustomObject]@{
        OGName = $ogName
        OGId = $ogID
    }

    Return $ogInfo
}

 Function Get-UEM-Content {

    Param ([object]$headers, [string]$ogName, [int]$ogID, [string]$pageURL)

    # Create an audit file so there is some way to validate if the downloaded content
    # looks correct.
    $baseFolder = $runParams.BaseFolder
    if ((Test-Path -Path $baseFolder) -ne $true) {
        New-Item -Path $baseFolder -ItemType Directory
    }

    if ($pageURL -eq "FirstPage") {
        $uemHost = $runParams.UEMConsole
        $contentEndpoint = "$uemHost/API/mcm/awcontents?locationgroupcode={ogname}&locationgroupid={ogid}"
        $contentEndpoint = $contentEndpoint.Replace("{ogname}", $ogName)
        $contentEndpoint = $contentEndpoint.Replace("{ogid}", $ogID)
    } else {
        $contentEndpoint = $pageURL.Replace("http://", "https://")
    }
    $webReturn = Invoke-RestMethod -Method Get -Uri $contentEndpoint -Headers $headers

    foreach ($currentContent in $webReturn.AWContents) {
        $category = $currentContent.Categories[0].Name
        $downloadID = $currentContent.ContentVersion.contentVersionId
        $fileName = $currentContent.name
        $downloadLink = $currentContent.ContentVersion.downloadLink
        $fileSize = $currentContent.ContentVersion.size
        $fileHash = $currentContent.ContentVersion.hash
        Download-Content $category $downloadLink $fileName $headers
    }

    $returnLink = "End"
    $additionalLinks = $webReturn.AdditionalInfo.Links
    foreach ($currentLink in $additionalLinks) {
        $linkHREF = $currentLink.Href
        if ($currentLink.Rel -eq "next") {
            $returnLink = $currentLink.Href
        }
    }

    Return $returnLink
 }

 Function Download-Content {

     Param ([string]$category, [string]$downloadLink, [string]$fileName, [object]$headers)

     $baseFolder = $runParams.BaseFolder
     $baseFolder = "$baseFolder/$category"
     if (Test-Path -Path $baseFolder) {
        $fileName = "$baseFolder/$fileName"
    } else {
        New-Item -Path $baseFolder -ItemType Directory
        $fileName = "$baseFolder/$fileName"
    }
     
     $downloadLink = $downloadLink.Replace("http://", "https://")
     $uemHost = $runParams.UEMConsole
     $webReturn = Invoke-RestMethod -Method Get -Headers $headers -Uri $downloadLink -OutFile $fileName
 }

Main