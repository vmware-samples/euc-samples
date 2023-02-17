# Description: Returns Branch Cache DataCache CurrentSizeOnDiskAsNumberOfBytes details
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: INTEGER

$branchcache = (Get-BCStatus).DataCache.CurrentSizeOnDiskAsNumberOfBytes
return $branchcache
