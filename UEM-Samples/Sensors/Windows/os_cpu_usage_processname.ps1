# Returns the average amount of processor time that the process has used on all processors, in seconds.
# Return Type: Integer
# Execution Context: User
# change TaskScheduler to your process name
$cpu_usage=get-process TaskScheduler |measure-object -property CPU -Average |select-object -ExpandProperty Average
write-output ([System.Math]::Round($cpu_usage))

