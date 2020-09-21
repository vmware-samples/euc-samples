# Returns the system's IPv6 Address
# Return Type: String
# Execution Context: User
# Author: tvalcesia
# Cherry-Picked from PR:   https://github.com/vmware-samples/euc-samples/pull/120

$IPv6 = (Get-WmiObject win32_Networkadapterconfiguration | Where-Object{$_.ipaddress -notlike $null}).IPaddress[3]
Write-Output $IPv6 