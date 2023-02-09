# Description: Returns the last date and time that the device successfully completed OMA-DM sync.
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: DATETIME

$Account = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts
$SuccessTime = Get-ItemProperty -Path "Registry::$($Account.Name)\Protected\ConnInfo" -Name ServerLastSuccessTime
$SuccessTime = [Datetime]::ParseExact($SuccessTime.ServerLastSuccessTime.ToString(), 'yyyyMMdd\THHmmss\Z', $null)
Return $SuccessTime

