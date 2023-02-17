# Description: Returns True/False if a hypervisor is/is not present
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

$computer = Get-WmiObject -Class Win32_ComputerSystem 
return $computer.HypervisorPresent
