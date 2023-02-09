# Description: Returns the full charge (actual) capacity of the batteries in mWh 
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: INTEGER

if ((Get-WmiObject -Class Win32_Battery).count -ne 0){
	$max_capacity = (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI").FullChargedCapacity
	$max_capacity = '{0:N0}' -f $max_capacity
	return $max_capacity
} else {
	return 0
}

