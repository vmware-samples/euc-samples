# Returns the estimated remaining charge on the battery
# Return Type: String
# Execution Context: System

# Check for existence of battery
if ((Get-WmiObject -Class Win32_Battery).count -ne 0)
{
	
	$battery_remain = (Get-WmiObject win32_battery).estimatedChargeRemaining
    write-output "$battery_remain%"
}
else
{
	Write-Output "No battery found"
}
