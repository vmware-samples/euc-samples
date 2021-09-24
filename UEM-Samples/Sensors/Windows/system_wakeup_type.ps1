# Returns the even that casued the system to power up. Possible values include: other, unknown, APM Timer, Modem Ring, LAN Remote, Power Switch, PCI PME#, or AC Power Restored.
# Return Type: String
# Execution Context: User
$computer = Get-WmiObject -Class Win32_ComputerSystem 
switch ($computer.WakeUpType) {
0 {"Reserved"}
1 {"Other"}
2 {"Unknown"}
3 {"APM Timer"}
4 {"Modem Ring"}
5 {"LAN Remote"}
6 {"Power Switch"}
7 {"PCI PME#"}
8 {"AC Power Restored"}
}