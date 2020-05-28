# Returns Branch Cache HashCache details 
# Example - Filepath, default
# Get-BCStatus | Select-Object -ExpandProperty HashCache | Select-Object -ExpandProperty CacheFileDirectoryPath
# Return Type: String
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty HashCache
write-output $branchcache.CacheFileDirectoryPath
