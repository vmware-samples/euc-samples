# Description: Report Status of Windows Update of a device, rather than individual updates. Responses include - Up-To-Date | Pending Reboot | Out-of-Date | Update-Failed | No Status
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$timeout = 120 ## seconds

#script block for background job
$CheckUpdates = {
    $LogFilePath = "C:\Temp\ws1"
    if (!(Test-Path -Path $LogFilePath))
    {
        New-Item -Path $LogFilePath -ItemType Directory | Out-Null
    }
    
    $Logfile = $LogFilePath+"\checkUpdates.log"
    
    Function Log([string]$level, [string]$logstring)
    {
        $rightSide = [string]::join("   ", ($level, $logstring))
    
        $date = Get-Date -Format g
        $logEntry = [string]::join("    ", ($date, $rightSide)) 
        Add-content $Logfile -value $logEntry
    }
    
    $testnet = Test-NetConnection -ComputerName www.catalog.update.microsoft.com -CommonTCPPort HTTP
    if($testnet.TcpTestSucceeded -eq "True"){}Else{return "No Connection"}

    $Sysinfo = New-Object -ComObject Microsoft.Update.SystemInfo
    $pending = $Sysinfo.RebootRequired
    if($pending){return "Pending Reboot"}
        
    $Session = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session"))#,$Computer))
    $UpdateSearcher = $Session.CreateUpdateSearcher()
    $TotalHistoryCount = $UpdateSearcher.GetTotalHistoryCount()
    $UpdateHistory = $UpdateSearcher.QueryHistory(0,$TotalHistoryCount)
        
    $Criteria = "IsHidden=0 and IsInstalled=0 and IsAssigned=1"
    
    try{
        $SearchResult = $UpdateSearcher.Search($Criteria).Updates
    }catch{
        Log "Error" "$($_.Exception)"
        return "Update Search Failed"
    }

    $FailedUpdates = @()
        
    if($SearchResult.count -ne 0){
        foreach ($entry in $SearchResult){
            $cond=$false
            foreach ($record in $UpdateHistory){
                if($record.Date -gt (Get-Date).AddDays(-2) -and $entry.Identity.updateID -eq $record.UpdateIdentity.updateID -and $record.ResultCode -eq 4){
                    $cond=$true
                }
            }
            if($cond){
                $FailedUpdates += $entry
            }
        }
        
        if($FailedUpdates.count -ne 0){
            return "Updates Failed"
        }
        return "Updates Available"
    }
    else{
        return "Up to Date"
    }
}

#start the background job
$job = Start-Job -ScriptBlock $CheckUpdates

#retrieve job data after timeout
if ((Wait-Job $job -Timeout $timeout) -ne $null) {
    #get current job result
    Receive-Job $job
}

else{
    #force removing the job after timeout
    Remove-Job -force $job

    #return timeout if no result returned before
    return "action timed out"
}

