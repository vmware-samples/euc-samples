# Description: Returns True or False depending if the system is part of a domain
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

$computer = Get-WmiObject -Class Win32_ComputerSystem
Return $computer.PartOfDomain

