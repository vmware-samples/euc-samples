# Returns the current OMA-DM status (HEX) or error code. 0 = success; else return error code e.g. 0x80072f30
# Return Type: String
# Execution Context: System
$Account = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts
$LastSessionResult = Get-ItemProperty -Path "Registry::$($Account.Name)\Protected\ConnInfo" -Name LastSessionResult
$HEX = "{0:x}" -f $LastSessionResult.LastSessionResult
Write-Output $HEX