# Returns Branch Cache DataCache details 
# Example - MaxCacheSizeAsPercentageOfDiskVolume
# Get-BCStatus | Select-Object -ExpandProperty DataCache | Select-Object -ExpandProperty MaxCacheSizeAsPercentageOfDiskVolume
# Return Type: Integer
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty DataCache
write-output $branchcache.MaxCacheSizeAsPercentageOfDiskVolume
