# Description: Returns the computer name according to the DNS.
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$computer = Get-WmiObject -Class Win32_ComputerSystem 
Return $computer.DNSHostName

