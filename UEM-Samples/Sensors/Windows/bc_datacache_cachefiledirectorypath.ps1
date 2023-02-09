# Description: Returns Branch Cache DataCache CacheFileDirectoryPath details. Returns - Default/a file path
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$branchcache = (Get-BCStatus).DataCache.CacheFileDirectoryPath
return $branchcache
