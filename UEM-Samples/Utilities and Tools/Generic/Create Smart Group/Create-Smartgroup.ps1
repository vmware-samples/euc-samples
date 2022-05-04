<#
.SYNOPSIS
Create Smart Group in Workspace ONE UEM from CSV file.

.NOTES
Version:        1.1
Creation Date:  04/28/2022
Author:         Ryan Pringnitz - rpringnitz@vmware.com
Author:         Ty Edwards - edwardsty@vmware.com
Author:         Alex Chau - achau@vmware.com
Author:         Made with love in Kalamazoo, Michigan, Fredericksburg, Virginia & Atlanta, Georgia
Purpose/Change: Initial Release

#>

#----------------------------------------------------------[Declarations]----------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function Get-Environment {
    
    if ([string]::IsNullOrEmpty($script:WSOServer)) {
        $script:WSOServer = Read-Host -Prompt 'Enter the Workspace ONE UEM Server Name'       
    }
    if ([string]::IsNullOrEmpty($script:apiKey)) {
        $script:apiKey = Read-Host -Prompt 'Enter the Workspace ONE UEM API Key'       
    }
    if ([string]::IsNullOrEmpty($script:cred)) {
        $script:cred = Get-Credential -Message 'Enter credentials to access the Workspace ONE UEM API'
    }
    if ([string]::IsNullOrEmpty($script:csvFile)) {
        $script:csvFile = Read-Host -Prompt 'Enter the CSV filename containing hostnames'
    }
    if ([string]::IsNullOrEmpty($script:lgid)) {
        $script:lgid = Read-Host -Prompt 'Enter the organization group ID'
    }
    if ([string]::IsNullOrEmpty($script:orgUuid)) {
        $script:orgUuid = Read-Host -Prompt 'Enter the organization group UUID'
    }
    if ([string]::IsNullOrEmpty($script:smartGroupName)) {
        $script:smartGroupName = Read-Host -Prompt 'Enter the smart group name'
    }
    
    $script:header = @{
        "aw-tenant-code" = $apiKey;
        "Accept"         = "application/json";
        "Content-Type"   = "application/json";
    }
    
    return $script:header, $script:WSOServer, $script:apiKey, $script:cred, $script:csvFile, $script:lgid, $script:orgUuid
}
Function Get-Devices {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$WSOServer,
        [string]$lgid,
        [HashTable]$header,
        [PSCredential]$Credential   
    )
    
    try {
        $pagesize = 500
        $script:devices = @()
        $pageloop = 0
        $script:devices += Invoke-RestMethod -Uri "$WSOServer/API/mdm/devices/search?lgid=$lgid&page=0&pagesize=$pagesize" -Headers $header -Credential $cred
        $pages = $devices[$pageloop].Total / $pagesize
        $pages = "{0:f0}" -f $pages
        $pageloop++
        for (; $pageloop -le $pages; ) {
            $script:devices += Invoke-RestMethod -Uri "$WSOServer/API/mdm/devices/search?lgid=$lgid&page=$pageloop&pagesize=$pagesize" -Headers $header -Credential $cred
            $pageloop++
        }
        Write-host $script:devices.Devices.Count "devices found"
        $script:devices = $script:devices.Devices        
        return $script:devices
    }
    catch {
        Write-Host "An error occurred when logging on $_"
        break
    }  
}    
Function Get-DistinctCsvDevices {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$csvFile    
    )
    $script:csvDevices = import-csv -Path $csvFile -Header 'DeviceName' | Sort-Object * -Unique
    return $script:csvDevices
}
Function New-UemApiBody {
    Param(
        [Parameter(Mandatory = $true)]
        $csvDevices,
        [string]$lgid,
        [string]$orggroupUUID,
        [string]$smartGroupName 
    )
    $devMatches = @()
    # Matches device hostnames from CSV to GET request, filters for deviceIDs for those hostnames and stores as PSCustomObject
    foreach ($line in $csvDevices) {
        $devMatches += $Devices | Where-Object "DeviceReportedName" -EQ $line.DeviceName
    }
    $script:DeviceIDs = $devMatches.id.value

    # Create Custom Object with each DeviceId stored in JSON 
    $obj = @()
    $obj | Add-Member -type NoteProperty -Name Id
    ForEach ($updateddeviceid in $DeviceIDs) {
        $obj += New-Object -TypeName psobject -Property  @{Id = "$updateddeviceid" }
    }
    $obj = $obj | ConvertTo-Json

    # Create body for POST request to create smart group
    $script:body = "{
    `n  `"Name`": `"$smartGroupName`",
    `n  `"CriteriaType`": `"UserDevice`",
    `n  `"ManagedByOrganizationGroupId`": `"$lgid`",
    `n  `"OrganizationGroups`": [`n    
                                    {
                                        `n      `"Name`": `"Windows`",
                                        `n      `"Id`": `"$lgid`",
                                        `n      `"Uuid`": `"$orggroupUUID`"
                                        `n    }`n  ],
                                        `n  `"DeviceAdditions`": 
                                        `n    
                                        `n     $obj
                                        `n    
                                        `n 
                                        `n
                                        }"

    return $script:body
}
Function Invoke-CreateSmartGroup {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$WSOServer,
        [HashTable]$header,
        [PSCredential]$Credential,
        [string]$body 
    )
        
    try {
            Invoke-RestMethod -Uri "$WSOServer/API/mdm/smartgroups" -Method 'POST' -Headers $header -Body $body -Credential $cred
    }
    catch {
        Write-Host "An error occurred when logging on $_"
        break
    }
}
    
Function Show-Menu {
    param (
        [string]$Title = 'VMware Workspace ONE UEM API Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "Press '1' to enter environment and smart group details"
    Write-Host "Press '2' to Retrieve CSV file and create smart group"
    Write-Host "Press 'Q' to quit."
}
    
do {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection) {
            
        '1' { 
            Get-Environment 
        } 
            
        '2' {
            Get-Devices -WSOServer $WSOServer -header $header -Credential $cred -lgid $lgid
            Get-DistinctCsvDevices -csvFile $csvFile
            New-UemApiBody -csvDevices $csvDevices -lgid $lgid -orggroupUUID $orggroupUUID -smartGroupName $smartGroupName
            Invoke-CreateSmartGroup -WSOServer $WSOServer -header $header -body $body -Credential $cred
        }
            
    }
    pause
}
until ($selection -eq 'Q')