<# 
  .Synopsis
  Check existance of WSUS registry keys, remove keys and report status.
  .NOTES
  Created:	November, 2022
  Created by:	Phil Helmling, @philhelmling
  Organization:	VMware, Inc.
  .DESCRIPTION
  Used to check existance of WSUS registry keys, remove keys and report status. Status' reported:
  - "WSUS removed" if device had registry keys
  - "WSUS not configured" if no registry keys detected

  Return Type: String
  Execution Context: System
  Execution Architecture: Auto
#>
$regpath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
$checkregistry= Test-Path $regpath

if ($checkregistry){ 
  Remove-Item -Path $regpath -Recurse -Force
  $status = "WSUS removed"
} else {
  $status = "WSUS not configured"
}
return $status