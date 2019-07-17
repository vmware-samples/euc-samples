# Returns load capacity of each processor, averaged to the last second.
# Return Type: Integer
# Execution Context: User
$cpu_usage=Get-WmiObject win32_processor | Select-Object -ExpandProperty LoadPercentage
write-output ([System.Math]::Round($cpu_usage))
