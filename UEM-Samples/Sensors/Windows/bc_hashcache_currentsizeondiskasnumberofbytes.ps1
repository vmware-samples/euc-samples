# Description: Returns Branch Cache HashCache CurrentSizeOnDiskAsNumberOfBytes details
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: INTEGER

$branchcache = (Get-BCStatus).HashCache.CurrentSizeOnDiskAsNumberOfBytes
return $branchcache
