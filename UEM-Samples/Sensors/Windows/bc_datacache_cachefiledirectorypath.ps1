# Returns Branch Cache DataCache details 
# Example - Filepath, default
# Get-BCStatus | Select-Object -ExpandProperty DataCache | Select-Object -ExpandProperty CacheFileDirectoryPath
# Return Type: Integer
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty DataCache
write-output $branchcache.CacheFileDirectoryPath
