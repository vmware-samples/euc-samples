# Description: Returns Branch Cache Client Service Startup Type
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$branchcache = (Get-BCStatus).BranchCacheServiceStartType
return $branchcache
