# Returns the last date and time that the device last attempted a OMA-DM sync.
# Return Type: DateTime
# Execution Context: System
$Account = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts
$AccessTime = Get-ItemProperty -Path "Registry::$($Account.Name)\Protected\ConnInfo" -Name ServerLastAccessTime
$AccessTime = [Datetime]::ParseExact($AccessTime.ServerLastAccessTime.ToString(), 'yyyyMMdd\THHmmss\Z', $null)
Write-Output $AccessTime