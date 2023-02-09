# Description: Returns True/False if a hypervisor is/is not present
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$computer = Get-WmiObject -Class Win32_ComputerSystem 
return $computer.HypervisorPresent
