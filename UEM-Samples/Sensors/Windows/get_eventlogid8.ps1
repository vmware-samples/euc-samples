# Description: Returns value of 1 if Event ID is found in Windows Event Log
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: INTEGER
# V@riables: Log,System; Id,8
# future add ability to use variable to specify the log and event id to return

#Variables to modify
$StartTime = (Get-Date).AddDays(-1) #1 day prior to now
$EndTime = Get-Date
$Log = 'System'
$Id = '8'

$filterTable = @{'StartTime' = $StartTime
'EndTime' = $EndTime
'LogName' = $Log
'Id' = $Id
}
$Events = Get-WinEvent -FilterHashTable $filterTable -ea 'SilentlyContinue'

if($Events){return 1}else{return 0}

