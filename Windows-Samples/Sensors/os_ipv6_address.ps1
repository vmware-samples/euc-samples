# Returns the system's IPv6 Address
# Return Type: String
# Execution Context: User
# Author: tvalcesia

$IPv6 = (Get-WmiObject win32_Networkadapterconfiguration | Where-Object{$_.ipaddress -notlike $null}).IPaddress[3]
Write-Output $IPv6 