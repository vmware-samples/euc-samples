# Description: Returns Branch Cache Client Configuration details CurrentClientMode. Returns - True, False
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

$branchcache = (Get-BCStatus).ClientConfiguration.HostedCacheDiscoveryEnabled
return $branchcache
