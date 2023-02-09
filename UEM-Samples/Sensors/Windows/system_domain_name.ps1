# Description: Returns domain name of currently joined domain or Workgroup if not in a domain
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$computer = Get-WmiObject -Class Win32_ComputerSystem
Return $computer.Domain

