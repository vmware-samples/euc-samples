# Returns the system's IPv4 Address
# Return Type: String
# Execution Context: User
# Author: tvalcesia
# Cherry-Picked from PR:   https://github.com/vmware-samples/euc-samples/pull/120

$IPv4 = (Get-WmiObject win32_Networkadapterconfiguration | Where-Object{$_.ipaddress -notlike $null}).IPaddress | Select-Object -First 1
Write-Output $IPv4 