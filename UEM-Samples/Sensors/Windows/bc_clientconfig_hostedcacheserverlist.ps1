# Description: Returns BranchCache Client Configuration details HostedCacheServerList
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$branchcache = (Get-BCStatus).ClientConfiguration.HostedCacheServerList
return $branchcache
