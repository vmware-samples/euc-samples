# Description: Returns network usage (in KB)
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$Total_bytes=Get-WmiObject -class Win32_PerfFormattedData_Tcpip_NetworkInterface |Measure-Object -property BytesTotalPersec -Average |Select-Object -ExpandProperty Average
$totalKilobytes = ([System.Math]::Round($Total_bytes)/1KB).ToString("0.00")
Return "$totalKilobytes KB"

