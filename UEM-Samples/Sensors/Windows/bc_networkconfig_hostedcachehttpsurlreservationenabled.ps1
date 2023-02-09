# Description: Returns Branch Cache NetworkConfiguration HostedCacheHttpsUrlReservationEnabled status. Returns true/false
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$branchcache = (Get-BCStatus).NetworkConfiguration.HostedCacheHttpsUrlReservationEnabled
return $branchcache

