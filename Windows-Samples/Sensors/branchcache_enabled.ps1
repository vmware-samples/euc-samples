# Returns true if BranchCache is Enabled
# Return Type: Boolean
# Execution Context: System
$brachcache = Get-BCStatus
write-output $brachcache.BranchCacheIsEnabled