# Returns used network in bytes
# Return Type: Integer
# Execution Context: User
$Total_bytes=Get-WmiObject -class Win32_PerfFormattedData_Tcpip_NetworkInterface |Measure-Object -property BytesTotalPersec -Average |Select-Object -ExpandProperty Average
write-output ([System.Math]::Round($Total_bytes))

