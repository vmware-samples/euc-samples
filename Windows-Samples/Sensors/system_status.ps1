# Returns the curren status of the system. Operational statuses include: OK, Degraded, and Pred Fail, which is an element such as a SMART-enabled hard disk drive that may be functioning properly, but predicts a failure in the near future. Nonoperational statuses include: Error, Starting, Stopping, and Service, which can apply during mirror-resilvering of a disk, reloading a user permissions list, or other Systemistrative work. Not all status work is online, but the managed element is not OK or in one of the other states.
# Return Type: String
# Execution Context: User
$computer = Get-WmiObject -Class Win32_ComputerSystem 
write-output $computer.Status