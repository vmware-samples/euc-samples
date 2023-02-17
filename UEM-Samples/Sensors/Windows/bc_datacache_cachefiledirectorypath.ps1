# Description: Returns Branch Cache DataCache CacheFileDirectoryPath details. Returns - Default/a file path
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$branchcache = (Get-BCStatus).DataCache.CacheFileDirectoryPath
return $branchcache
