<#
.SYNOPSIS
Script to sync devices in Workspace ONE UEM

.NOTES
Version:        1.0
Creation Date:  09/03/2021
Author:         Ryan Pringnitz - rpringnitz@vmware.com
Author:         Made with love in Kalamazoo, Michigan
Purpose/Change: Initial Release

#>

#----------------------------------------------------------[Declarations]----------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function Get-Environment {
    $script:config = "$PSScriptRoot\config.ini"
    Write-Host Getting config from $config
    $WS1Env = Get-Content -Path "$config" | Select -Skip 1 | ConvertFrom-StringData
    $script:WSOServer = $WS1Env.Environment
    $script:apiKey = $WS1Env.apikey
    $script:b64 = $WS1Env.b64
    $encodedString = "Basic " + $b64
    $script:header = @{
        "Authorization" = $encodedString; 
        "aw-tenant-code" = $apiKey; 
        "Accept" = "application/json"; 
        "Content-Type" = "application/json"
    }
    return $script:header,$script:WSOServer
}
Function Get-Devices {
    Param(
    [Parameter(Mandatory=$true)]
    [string]$WSOServer,
    [HashTable]$header  
    )
    
    try {
        $pagesize = 500
        $script:devices = @()
        $pageloop = 0
        $ServicePoint = [System.Net.ServicePointManager]::FindServicePoint($WSOServer)
        $script:devices += Invoke-RestMethod -Uri "$WSOServer/API/mdm/devices/search?page=0&pagesize=$pagesize" -Headers $header 
        $ServicePoint.CloseConnectionGroup("")
        $assignedPages = $devices[$pageloop].Total / $pagesize
        $assignedPages = "{0:f0}" -f $assignedPages
        $pageloop++
        $apiCounter++
        for (;$pageloop -le $assignedPages;) {
            $ServicePoint = [System.Net.ServicePointManager]::FindServicePoint($WSOServer)
            $script:devices += Invoke-RestMethod -Uri "$WSOServer/API/mdm/devices/search?page=$pageloop&pagesize=$pagesize" -Headers $header 
            $ServicePoint.CloseConnectionGroup("")
            $pageloop++
        }
        Write-host $script:devices.Devices.Count "devices found"        
        return $script:devices
    } catch {
        Write-Host "An error occurred when logging on $_"
        break
    }  
}    
Function Get-EnrolledDevice {
    Param(
    [Parameter(Mandatory=$true)]
    [System.Object]$Devices    
    )
    $script:enrolledDevices = $Devices.Devices | Where-Object { $_.EnrollmentStatus -eq 'Enrolled'}
    return $script:enrolledDevices
}
Function Get-DeviceId {
    Param(
    [Parameter(Mandatory=$true)]
    [System.Object]$EnrolledDevices    
    )
    $script:id = $enrolledDevices.Id.Value
    return $script:id
}
Function Invoke-DeviceSync {
    Param(
    [Parameter(Mandatory=$true)]
    [System.Object]$DeviceId,
    [string]$WSOServer,
    [HashTable]$header
    )
        
        try {
            foreach ($devID in $id){ 
                $ServicePoint = [System.Net.ServicePointManager]::FindServicePoint($WSOServer)
                Invoke-WebRequest -Uri "$WSOServer/API/mdm/devices/$devID/commands?command=SyncDevice" -Headers $header -Method 'POST'
                $ServicePoint.CloseConnectionGroup("")
            }
        } catch {
            Write-Host "An error occurred when logging on $_"
            break
        }
    }
    function Invoke-AutoDeviceSync {
        Get-Environment 
        Get-Devices -WSOServer $WSOServer -header $header
        Get-EnrolledDevice -Devices $devices
        Get-DeviceId -EnrolledDevices $enrolledDevices
        Invoke-DeviceSync -DeviceId $id -WSOServer $WSOServer -header $header
    }


    Invoke-AutoDeviceSync
    