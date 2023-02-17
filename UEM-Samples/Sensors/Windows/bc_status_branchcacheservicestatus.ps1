# Description: Returns Branch Cache Client Service Status
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$branchcache = (Get-BCStatus).BranchCacheServiceStatus
return $branchcache
