# Returns the name of the systems Model
# Return Type: String
# Execution Context: User
$computer = Get-WmiObject -Class Win32_ComputerSystem 
write-output $computer.Model