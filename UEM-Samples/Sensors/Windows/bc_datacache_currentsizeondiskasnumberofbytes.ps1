# Returns Branch Cache DataCache details 
# Example - CurrentSizeOnDiskAsNumberOfBytes
# Get-BCStatus | Select-Object -ExpandProperty DataCache | Select-Object -ExpandProperty CurrentSizeOnDiskAsNumberOfBytes
# Return Type: Integer
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty DataCache
write-output $branchcache.CurrentSizeOnDiskAsNumberOfBytes
