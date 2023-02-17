# Description: Returns the last date and time that the device failed the OMA-DM sync.
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: DATETIME

$Account = Get-ChildItem -Path "Registry::HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts" -ErrorAction SilentlyContinue
$ConnInfo = Get-ItemPropertyValue -Path "Registry::$($Account.Name)\Protected\ConnInfo" -Name "ServerLastFailureTime" -ErrorAction SilentlyContinue
if($ConnInfo){
  $FailTime = [Datetime]::ParseExact($ConnInfo.ServerLastFailureTime.ToString(), 'yyyyMMdd\THHmmss\Z', $null)
  Return $FailTime
}

