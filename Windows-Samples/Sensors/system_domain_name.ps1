# Returns domain name of currently joined domain, or Workgroup if not in a domain
# Return Type: String
# Execution Context: User
$computer = Get-WmiObject -Class Win32_ComputerSystem
write-output $computer.Domain