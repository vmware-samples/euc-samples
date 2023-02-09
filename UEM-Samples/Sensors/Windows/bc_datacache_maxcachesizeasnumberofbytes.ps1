# Description: Returns Branch Cache DataCache MaxCacheSizeAsNumberOfBytes details
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: INTEGER

$branchcache = (Get-BCStatus).DataCache.MaxCacheSizeAsNumberOfBytes
return $branchcache
