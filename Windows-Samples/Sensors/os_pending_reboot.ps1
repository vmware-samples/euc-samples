# Return Type: String
# Execution Context: User
$pendingRebootWinUpdate = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired')
if ($pendingRebootWinUpdate)
{return $true}
else
{return $false}