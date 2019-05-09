# Returns the Service state for the Branch Cache Service e.g. Stopped/Running
# Return Type: String
# Execution Context: System
$brachcache = Get-BCStatus
write-output $brachcache.BranchCacheServiceStatus