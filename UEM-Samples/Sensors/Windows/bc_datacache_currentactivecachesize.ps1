# Description: Returns Branch Cache DataCache details
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: INTEGER

$branchcache = (Get-BCStatus).DataCache.CurrentActiveCacheSize
return $branchcache
