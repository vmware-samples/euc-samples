# Returns username of the user using the device 
# Return Type: String
# Execution Context: User
$computer = Get-WmiObject -Class Win32_ComputerSystem 
write-output $computer.UserName