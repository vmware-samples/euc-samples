# Description: Returns True/False whether a devices is pending a reboot from a Windows Update(s)
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$pendingRebootWinUpdate = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired')
if ($pendingRebootWinUpdate)
{return $true}
else
{return $false}

