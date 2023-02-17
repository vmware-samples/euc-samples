# Description: Returns Branch Cache HashCache CurrentActiveCacheSize details
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: INTEGER

$branchcache = (Get-BCStatus).HashCache.CurrentActiveCacheSize
return $branchcache
