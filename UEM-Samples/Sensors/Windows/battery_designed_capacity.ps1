# Description: Returns the max charge capacity of the batteries in mWh (megawatt hour)
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: INTEGER

if ((Get-WmiObject -Class Win32_Battery).count -ne 0) {
	$designedCapacity = (Get-WmiObject -Class "BatteryStaticData" -Namespace "ROOT\WMI").DesignedCapacity
	# add the following line to add formatting for thousands
	#$designedCapacity = '{0:N0}' -f $designedCapacity
	return $designedCapacity
} else {
	return 0
}

