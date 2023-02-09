# Description: Returns True or False depending if the system is part of a domain
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$computer = Get-WmiObject -Class Win32_ComputerSystem
Return $computer.PartOfDomain

