# Returns Branch Cache HashCache details 
# Example - CurrentSizeOnDiskAsNumberOfBytes
# Get-BCStatus | Select-Object -ExpandProperty HashCache | Select-Object -ExpandProperty CurrentSizeOnDiskAsNumberOfBytes
# Return Type: Integer
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty HashCache
write-output $branchcache.CurrentSizeOnDiskAsNumberOfBytes
