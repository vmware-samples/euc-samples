# Description: Returns the max charge capacity of the batteries as an integer
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: INTEGER

if ((Get-WmiObject -Class Win32_Battery).count -ne 0) {
	$designedCapacity = (Get-WmiObject -Class "BatteryStaticData" -Namespace "ROOT\WMI").DesignedCapacity
	$fullCharge = (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI").FullChargedCapacity
	# 
	$currentBatteryCapacity = ($FullCharge / $DesignedCapacity) * 100
	# Round battery percentage
	$currentBatteryCapacity = [decimal]::round($currentBatteryCapacity)
	return $currentBatteryCapacity
}
else
{
	return 0
}
