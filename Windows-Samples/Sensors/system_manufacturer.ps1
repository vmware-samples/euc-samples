# Returns the name of the systems manufacturer
# Return Type: String
# Execution Context: User
$computer = Get-WmiObject -Class Win32_ComputerSystem 
write-output $computer.Manufacturer