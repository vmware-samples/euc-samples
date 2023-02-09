# Description: Returns Branch Cache DataCache CurrentSizeOnDiskAsNumberOfBytes details
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: INTEGER

$branchcache = (Get-BCStatus).DataCache.CurrentSizeOnDiskAsNumberOfBytes
return $branchcache
