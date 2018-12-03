# Returns True or False depending if the system is part of a domain
# Return Type: Boolean
# Execution Context: User
$computer = Get-WmiObject -Class Win32_ComputerSystem
write-output $computer.PartOfDomain