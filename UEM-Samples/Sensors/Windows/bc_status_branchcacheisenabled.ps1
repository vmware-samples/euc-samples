# Description: Returns Branch Cache Client Status. Returns true/false
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

$branchcache = (Get-BCStatus).BranchCacheIsEnabled
return $branchcache
