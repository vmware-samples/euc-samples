# Returns Branch Cache DataCache details 
# Example - MaxCacheSizeAsNumberOfBytes
# Get-BCStatus | Select-Object -ExpandProperty DataCache | Select-Object -ExpandProperty MaxCacheSizeAsNumberOfBytes
# Return Type: Integer
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty DataCache
write-output $branchcache.MaxCacheSizeAsNumberOfBytes
