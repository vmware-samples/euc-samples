# Returns the last date and time that the device failed the OMA-DM sync.
# Return Type: DateTime
# Execution Context: System
$Account = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts
$FailTime = Get-ItemProperty -Path "Registry::$($Account.Name)\Protected\ConnInfo" -Name ServerLastFailureTime
$FailTime = [Datetime]::ParseExact($FailTime.ServerLastFailureTime.ToString(), 'yyyyMMdd\THHmmss\Z', $null)
Write-Output $FailTime