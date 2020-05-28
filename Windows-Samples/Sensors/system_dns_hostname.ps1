# Returns the computer name according to the DNS.
# Return Type: String
# Execution Context: User
$computer = Get-WmiObject -Class Win32_ComputerSystem 
write-output $computer.DNSHostName
