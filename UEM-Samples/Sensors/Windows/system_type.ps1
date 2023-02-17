# Description: Returns the system type.
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$computer = Get-WmiObject -Class Win32_ComputerSystem 
return $computer.SystemType
