# Description: Returns Branch Cache HashCache CacheFileDirectoryPath. Returns default/file path
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$branchcache = (Get-BCStatus).HashCache.CacheFileDirectoryPath
return $branchcache
