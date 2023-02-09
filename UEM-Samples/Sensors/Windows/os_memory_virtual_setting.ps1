# Description: Returns the maximum size (in MB) of the current paging file
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$virtualsize = Get-WmiObject Win32_PageFileSetting | where name -EQ "C:\pagefile.sys" | select MaximumSize
if ($virtualsize) 
{Return "$virtualsize MB"} 
 else 
{Return "Paging file info not available"}

