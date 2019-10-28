# Returns the max charge capacity of the batteries in mWh (megawatt hour)
# Return Type: String
# Execution Context: System
# Author: Bpeppin

# Check for existence of battery
if ((Get-WmiObject -Class Win32_Battery).count -ne 0)
{
	
	$designedCapacity = (Get-WmiObject -Class "BatteryStaticData" -Namespace "ROOT\WMI").DesignedCapacity
	$designedCapacity = '{0:N0}' -f $designedCapacity
	Write-Output "$designedCapacity mWh"
}
else
{
	Write-Output "No battery found"
}
