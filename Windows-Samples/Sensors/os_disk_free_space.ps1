# Returns C: Drive Available Free Space (Bytes)
# Return Type: Integer
# Execution Context: System
$cdrive=Get-WmiObject -Class Win32_logicaldisk | where DeviceID -eq "C:" | Select-Object -Property "FreeSpace"
write-output $cdrive.FreeSpace

