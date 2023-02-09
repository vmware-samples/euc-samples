# Description: Returns the name of the systems manufacturer
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$computer = Get-WmiObject -Class Win32_ComputerSystem 
return $computer.Manufacturer
