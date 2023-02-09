# Description: Returns Branch Cache NetworkConfiguration HostedCacheHttpUrlReservationEnabled status. Returns true/false
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$branchcache = (Get-BCStatus).NetworkConfiguration.HostedCacheHttpUrlReservationEnabled
return $branchcache

