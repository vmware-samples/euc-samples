# Description: Returns the domain role of the system. 
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$computer = Get-WmiObject -Class Win32_ComputerSystem 
switch ($computer.DomainRole) {
0 {"Standalone Workstation"}
1 {"Member Workstation"}
2 {"Standalone Server"}
3 {"Member Server"}
4 {"Backup Domain Controller"}
5 {"Primary Domain Controller"}
}

