# Description: Returns Branch Cache HashCache CurrentSizeOnDiskAsNumberOfBytes details
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: INTEGER

$branchcache = (Get-BCStatus).HashCache.CurrentSizeOnDiskAsNumberOfBytes
return $branchcache
