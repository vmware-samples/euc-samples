# Description: Returns Branch Cache DataCache details
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: INTEGER

$branchcache = (Get-BCStatus).DataCache.CurrentActiveCacheSize
return $branchcache
