# Description: Returns true or false if Event ID is found in Windows Event Log. Use this sensor to report if an Event ID is reported in a Windows Event Log within the time window. Will return true if it finds an event with matching event id in matching event log
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

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

if($Events){return $true}else{return $false}
