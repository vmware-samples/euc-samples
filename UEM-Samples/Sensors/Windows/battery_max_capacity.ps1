# Returns the max charge capacity of the batteries
# Return Type: Integer
# Execution Context: User
$max_capacity = (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI").FullChargedCapacity | Measure-Object -Sum | Select-Object -ExpandProperty Sum
write-output $max_capacity


