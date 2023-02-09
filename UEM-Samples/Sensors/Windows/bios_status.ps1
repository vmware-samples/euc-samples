# Description: Returns the BIOS Status. Statuses include: "OK", "Degraded", and "Pred Fail" (an element, such as a SMART-enabled hard disk drive, may be functioning properly but predicting a failure in the near future). Nonoperational statuses include: "Error", "Starting", "Stopping", and "Service". The latter, "Service", could apply during mirror-resilvering of a disk, reload of a user permissions list, or other Systemistrative work. Not all such work is online, yet the managed element is neither "OK" nor in one of the other states.
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$bios = (Get-WmiObject -Class Win32_bios).Status
return $bios


