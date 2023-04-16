# Returns true if BranchCache is Enabled
# Return Type: Boolean
# Execution Context: System
$branchcache = Get-BCStatus
write-output $branchcache.BranchCacheIsEnabled