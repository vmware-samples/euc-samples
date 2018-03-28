function Write-Log {
    Param (
        [Parameter(Mandatory=$False)]
        [string]$logType = "Info",
        [Parameter(Mandatory=$True)]
        [string]$logString
    )
    
    $logDate = Get-Date -UFormat "%Y-%m-%d"
    $datetime = (Get-Date).ToString()
    $logPath = "$($env:ProgramData)\AirWatch\GPOs"
    if (!(Test-Path -Path $logPath)) { New-Item -Path $logPath -ItemType Directory | Out-Null }
     
    $logfilePath = "$logPath\log-$logDate.txt"
    "$dateTime | $logType | $logString" | Out-File -FilePath $logfilePath -Append
}

