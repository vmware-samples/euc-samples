# Returns Branch Cache HashCache details 
# Example - 0
# Get-BCStatus | Select-Object -ExpandProperty HashCache | Select-Object -ExpandProperty CurrentActiveCacheSize
# Return Type: Integer
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty HashCache
write-output $branchcache.CurrentActiveCacheSize
