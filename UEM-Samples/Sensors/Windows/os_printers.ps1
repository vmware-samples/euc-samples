# Description: Returns the current list of network printers
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$Printers = (Get-Printer | where type -eq "Connection").Name -join ','
if ($Printers) 
{
 Return $Printers
} 
else {Return "No network printers found"}

