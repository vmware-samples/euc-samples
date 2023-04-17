<#
.SYNOPSIS
Script to query devices in Workspace ONE UEM

.NOTES
Version:        1.0
Creation Date:  10/15/2021
Author:         Ryan Pringnitz - rpringnitz@vmware.com
Author:         Made with love in Kalamazoo, Michigan
Purpose/Change: Initial Release

#>

#----------------------------------------------------------[Declarations]----------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function Get-Environment {
    
    if ([string]::IsNullOrEmpty($script:WSOServer))
    {
        $script:WSOServer = Read-Host -Prompt 'Enter the Workspace ONE UEM Server Name'       
    }
    if ([string]::IsNullOrEmpty($script:apiKey))
    {
        $script:apiKey = Read-Host -Prompt 'Enter the Workspace ONE UEM API Key'       
    }
    if ([string]::IsNullOrEmpty($script:cred))
    {
        $script:cred = Get-Credential -Message 'Enter credentials to access the Workspace ONE UEM API'
    }
    
    $script:header = @{
        "aw-tenant-code" = $apiKey;
        "Accept"		 = "application/json";
        "Content-Type"   = "application/json";
    }
    
    return $script:header,$script:WSOServer,$script:apiKey,$script:cred
}
Function Get-Devices {
    Param(
    [Parameter(Mandatory=$true)]
    [string]$WSOServer,
    [HashTable]$header,
    [PSCredential]$Credential   
    )
    
    try {
        $pagesize = 500
        $script:devices = @()
        $pageloop = 0
        $ServicePoint = [System.Net.ServicePointManager]::FindServicePoint($WSOServer)
        $script:devices += Invoke-RestMethod -Uri "$WSOServer/API/mdm/devices/search?page=0&pagesize=$pagesize" -Headers $header -Credential $cred
        $ServicePoint.CloseConnectionGroup("")
        $assignedPages = $devices[$pageloop].Total / $pagesize
        $assignedPages = "{0:f0}" -f $assignedPages
        $pageloop++
        $apiCounter++
        for (;$pageloop -le $assignedPages;) {
            $ServicePoint = [System.Net.ServicePointManager]::FindServicePoint($WSOServer)
            $script:devices += Invoke-RestMethod -Uri "$WSOServer/API/mdm/devices/search?page=$pageloop&pagesize=$pagesize" -Headers $header -Credential $cred
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
Function Invoke-DeviceQuery {
    Param(
    [Parameter(Mandatory=$true)]
    [System.Object]$DeviceId,
    [string]$WSOServer,
    [HashTable]$header,
    [PSCredential]$Credential   
    )
        
        try {
            foreach ($devID in $id){ 
                $ServicePoint = [System.Net.ServicePointManager]::FindServicePoint($WSOServer)
                Invoke-WebRequest -Uri "$WSOServer/API/mdm/devices/$devID/commands?command=DeviceQuery" -Headers $header -Method 'POST' -Credential $cred
                $ServicePoint.CloseConnectionGroup("")
            }
        } catch {
            Write-Host "An error occurred when logging on $_"
            break
        }
    }
    function Show-Menu
    {
        param (
        [string]$Title = 'VMware Workspace ONE UEM API Menu'
        )
        Clear-Host
        Write-Host "================ $Title ================"
        Write-Host "Press '1' to get devices"
        Write-Host "Press '2' to query devices"
        Write-Host "Press 'Q' to quit."
    }
    
    do
    
    {
        Show-Menu
        $selection = Read-Host "Please make a selection"
        switch ($selection)
        {
            
            '1' { 
                Get-Environment 
                Get-Devices -WSOServer $WSOServer -header $header -Credential $cred
            } 
            
            '2' {
                Get-Environment
                Get-EnrolledDevice -Devices $devices
                Get-DeviceId -EnrolledDevices $enrolledDevices
                Invoke-DeviceQuery -DeviceId $id -WSOServer $WSOServer -header $header -Credential $cred
            }
            
        }
        pause
    }
    until ($selection -eq 'Q')
    