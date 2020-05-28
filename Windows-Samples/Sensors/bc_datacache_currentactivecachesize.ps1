# Returns Branch Cache DataCache details 
# Example - CurrentActiveCacheSize
# Get-BCStatus | Select-Object -ExpandProperty DataCache | Select-Object -ExpandProperty CurrentActiveCacheSize
# Return Type: Integer
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty DataCache
write-output $branchcache.CurrentActiveCacheSize
