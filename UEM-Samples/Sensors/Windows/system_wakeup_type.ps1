# Description: Returns the event that casued the system to power up. Possible values include: other, unknown, APM Timer, Modem Ring, LAN Remote, Power Switch, PCI PME#, or AC Power Restored.
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$computer = Get-WmiObject -Class Win32_ComputerSystem 
switch ($computer.WakeUpType) {
  0 {return "Reserved"}
  1 {return "Other"}
  2 {return "Unknown"}
  3 {return "APM Timer"}
  4 {return "Modem Ring"}
  5 {return "LAN Remote"}
  6 {return "Power Switch"}
  7 {return "PCI PME#"}
  8 {return "AC Power Restored"}
}
