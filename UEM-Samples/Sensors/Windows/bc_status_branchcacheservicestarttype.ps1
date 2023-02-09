# Description: Returns Branch Cache Client Service Startup Type
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$branchcache = (Get-BCStatus).BranchCacheServiceStartType
return $branchcache
