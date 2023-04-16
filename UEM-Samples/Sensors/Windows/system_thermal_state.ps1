# Returns the thermal state of the system when last booted. Possible values include: other, unknown, safe, warning, critical, and non-recoverable.
# Return Type: String
# Execution Context: User
$computer = Get-WmiObject -Class Win32_ComputerSystem 
switch ($computer.ThermalState) {
1 {"Other"}
2 {"Unknown"}
3 {"Safe"}
4 {"Warning"}
5 {"Critical"}
6 {"Non-recoverable"}
}