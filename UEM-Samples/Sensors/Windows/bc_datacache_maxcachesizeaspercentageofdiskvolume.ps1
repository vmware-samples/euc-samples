# Description: Returns Branch Cache DataCache MaxCacheSizeAsPercentageOfDiskVolume details 
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: INTEGER

$branchcache = (Get-BCStatus).DataCache.MaxCacheSizeAsPercentageOfDiskVolume
return $branchcache
