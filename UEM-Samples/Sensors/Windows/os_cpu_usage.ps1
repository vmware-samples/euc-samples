# Description: Returns load capacity of each processor, averaged to the last second.
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: INTEGER
# V@riables: process,win32_processor
# add ability to use Variables

$cpu_usage=Get-WmiObject win32_processor | Select-Object -ExpandProperty LoadPercentage
Return ([System.Math]::Round($cpu_usage))


