# Description: Returns BranchCache Client Configuration details HostedCacheServerList
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$branchcache = (Get-BCStatus).ClientConfiguration.HostedCacheServerList
return $branchcache
