# Description: Used to check existance of WSUS registry keys, remove keys and report status. Status' reported - "WSUS removed" if device had registry keys / "WSUS not configured" if no registry keys detected
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$regpath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
$checkregistry= Test-Path $regpath

if ($checkregistry){ 
  Remove-Item -Path $regpath -Recurse -Force
  $status = "WSUS removed"
} else {
  $status = "WSUS not configured"
}
return $status
