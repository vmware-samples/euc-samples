# Returns the type of system in use. Possible values: Unspecified, Desktop, Mobile, Workstation, Enterprise Server, SOHO Server, Appliance PC, Performance Server, Slate, Maximum. 
# Return Type: String
# Execution Context: User
$computer = Get-WmiObject -Class Win32_ComputerSystem 
switch ($computer.PCSystemTypeEx) {
0 {"Unspecified"}
1 {"Desktop"}
2 {"Mobile"}
3 {"Workstation"}
4 {"Enterprise Server"}
5 {"SOHO Server"}
6 {"Appliance PC"}
7 {"Performance Server"}
8 {"Slate"}
9 {"Maximum"}
}