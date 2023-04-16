# Returns the last date and time that the device successfully completed OMA-DM sync.
# Return Type: DateTime
# Execution Context: System
$Account = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts
$SuccessTime = Get-ItemProperty -Path "Registry::$($Account.Name)\Protected\ConnInfo" -Name ServerLastSuccessTime
$SuccessTime = [Datetime]::ParseExact($SuccessTime.ServerLastSuccessTime.ToString(), 'yyyyMMdd\THHmmss\Z', $null)
Write-Output $SuccessTime