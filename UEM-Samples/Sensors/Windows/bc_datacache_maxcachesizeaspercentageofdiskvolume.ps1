# Description: Returns Branch Cache DataCache MaxCacheSizeAsPercentageOfDiskVolume details 
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: INTEGER

$branchcache = (Get-BCStatus).DataCache.MaxCacheSizeAsPercentageOfDiskVolume
return $branchcache
