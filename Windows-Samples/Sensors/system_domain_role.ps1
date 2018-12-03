# Returns the domain domain role of the system. Possible values include: Standalone Workstation, Member Workstation, Standalone Server, Member Server, Backup Domain Controller, Primary Domain Controller. 
# Return Type: String
# Execution Context: User
$computer = Get-WmiObject -Class Win32_ComputerSystem 
switch ($computer.DomainRole) {
0 {"Standalone Workstation"}
1 {"Member Workstation"}
2 {"Standalone Server"}
3 {"Member Server"}
4 {"Backup Domain Controller"}
5 {"Primary Domain Controller"}
}