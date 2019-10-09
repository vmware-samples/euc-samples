# Returns the max charge capacity of the batteries in percentage
# Return Type: String
# Execution Context: System
# Author: Bpeppin

# Check for existence of battery
if ((Get-WmiObject -Class Win32_Battery).count -ne 0)
{
	
	$designedCapacity = (Get-WmiObject -Class "BatteryStaticData" -Namespace "ROOT\WMI").DesignedCapacity
	$fullCharge = (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI").FullChargedCapacity
	# 
	$currentBatteryCapacity = ($FullCharge / $DesignedCapacity) * 100
	# Round battery percentage
	$currentBatteryCapacity = [decimal]::round($currentBatteryCapacity)
	Write-Host "Battery capacity is at $($currentBatteryCapacity)%."
}
else
{
	Write-Output "No battery found"
}
