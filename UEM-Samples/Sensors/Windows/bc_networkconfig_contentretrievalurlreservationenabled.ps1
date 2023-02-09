# Description: Returns Branch Cache NetworkConfiguration ContentRetrievalUrlReservationEnabled status. Returns true/false
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$branchcache = (Get-BCStatus).NetworkConfiguration.ContentRetrievalUrlReservationEnabled
return $branchcache
