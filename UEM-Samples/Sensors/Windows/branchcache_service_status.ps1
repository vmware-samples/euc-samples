# Returns the Service state for the Branch Cache Service e.g. Stopped/Running
# Return Type: String
# Execution Context: System
$branchcache = Get-BCStatus
write-output $branchcache.BranchCacheServiceStatus