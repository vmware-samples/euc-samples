# Description: Returns the estimated remaining charge on the battery
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: INTEGER

if ((Get-WmiObject -Class Win32_Battery).count -ne 0) {
	$battery_remain = (Get-WmiObject win32_battery).estimatedChargeRemaining
  return $battery_remain
} else {
	return 0
}

