# Returns Branch Cache HashCache details 
# Example - In Bytes
# Get-BCStatus | Select-Object -ExpandProperty HashCache | Select-Object -ExpandProperty MaxCacheSizeAsNumberOfBytes
# Return Type: Integer
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty HashCache
write-output $branchcache.MaxCacheSizeAsNumberOfBytes
