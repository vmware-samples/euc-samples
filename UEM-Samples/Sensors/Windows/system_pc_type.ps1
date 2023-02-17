# Description: Returns the type of system in use. Possible values: Unspecified, Desktop, Mobile, Workstation, Enterprise Server, SOHO Server, Appliance PC, Performance Server, Slate, Maximum. 
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$computer = Get-WmiObject -Class Win32_ComputerSystem 
switch ($computer.PCSystemTypeEx) {
  0 {return "Unspecified"}
  1 {return "Desktop"}
  2 {return "Mobile"}
  3 {return "Workstation"}
  4 {return "Enterprise Server"}
  5 {return "SOHO Server"}
  6 {return "Appliance PC"}
  7 {return "Performance Server"}
  8 {return "Slate"}
  9 {return "Maximum"}
}
