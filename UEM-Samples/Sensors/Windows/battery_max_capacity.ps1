# Description: Returns the max charge capacity of the batteries
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: INTEGER

if ((Get-WmiObject -Class Win32_Battery).count -ne 0) {
	$max_capacity = (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI").FullChargedCapacity | Measure-Object -Sum | Select-Object -ExpandProperty Sum
	return $max_capacity
} else {
	return 0
}
