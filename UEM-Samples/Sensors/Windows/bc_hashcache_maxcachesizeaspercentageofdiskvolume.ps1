# Returns Branch Cache HashCache details 
# Example - 5
# Get-BCStatus | Select-Object -ExpandProperty HashCache | Select-Object -ExpandProperty MaxCacheSizeAsPercentageOfDiskVolume
# Return Type: Integer
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty HashCache
write-output $branchcache.MaxCacheSizeAsPercentageOfDiskVolume
