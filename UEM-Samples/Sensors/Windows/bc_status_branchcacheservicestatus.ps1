# Description: Returns Branch Cache Client Service Status
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$branchcache = (Get-BCStatus).BranchCacheServiceStatus
return $branchcache
