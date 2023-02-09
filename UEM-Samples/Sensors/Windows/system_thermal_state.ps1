# Description: Returns the thermal state of the system when last booted. Possible values include: other, unknown, safe, warning, critical, and non-recoverable.
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$computer = Get-WmiObject -Class Win32_ComputerSystem 
switch ($computer.ThermalState) {
  1 {return "Other"}
  2 {return "Unknown"}
  3 {return "Safe"}
  4 {return "Warning"}
  5 {return "Critical"}
  6 {return "Non-recoverable"}
}
