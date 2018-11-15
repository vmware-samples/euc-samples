# Returns the average amount of processor time that the process has used on all processors, in seconds.
# Return Type: Integer
# Execution Context: User
# change mcshield to your process name
$cpu_usage=get-process mcshield |measure-object -property CPU -Average |select-object -ExpandProperty Average
write-output ([System.Math]::Round($cpu_usage))

