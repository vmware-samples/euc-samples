# Description: Returns Branch Cache HashCache CacheFileDirectoryPath. Returns default/file path
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$branchcache = (Get-BCStatus).HashCache.CacheFileDirectoryPath
return $branchcache
