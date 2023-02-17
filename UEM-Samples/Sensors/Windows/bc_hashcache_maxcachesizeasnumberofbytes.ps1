# Description: Returns Branch Cache HashCache MaxCacheSizeAsNumberOfBytes details
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: INTEGER

$branchcache = (Get-BCStatus).HashCache.MaxCacheSizeAsNumberOfBytes
return $branchcache

