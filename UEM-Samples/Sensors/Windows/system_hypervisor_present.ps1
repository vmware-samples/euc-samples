# Returns True if a hypervisor is present
# Return Type: Boolean
# Execution Context: User
$computer = Get-WmiObject -Class Win32_ComputerSystem 
write-output $computer.HypervisorPresent