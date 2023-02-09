# Description: Returns the average amount of processor time that the process has used on all processors, in seconds. Change "TaskScheduler" to your process name
# Execution Context: USER
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: INTEGER

$cpu_usage=get-process "TaskScheduler" | measure-object -property CPU -Average | select-object -ExpandProperty Average
Return ([System.Math]::Round($cpu_usage/60))

