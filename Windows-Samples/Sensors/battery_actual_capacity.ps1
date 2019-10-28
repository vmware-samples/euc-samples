# Returns the full charge (actual) capacity of the batteries in mWh 
# Return Type: Integer
# Execution Context: System
# Author: bpeppin

# Check for existence of battery
if ((Get-WmiObject -Class Win32_Battery).count -ne 0)
{
	
	$max_capacity = (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI").FullChargedCapacity
	$max_capacity = '{0:N0}' -f $max_capacity
	Write-Host "$max_capacity mWh"
}
else
{
	Write-Output "No battery found"
}
