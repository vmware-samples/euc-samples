# Description: Returns Branch Cache HashCache MaxCacheSizeAsPercentageOfDiskVolume details
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: INTEGER

$branchcache = (Get-BCStatus).HashCache.MaxCacheSizeAsPercentageOfDiskVolume
return $branchcache
