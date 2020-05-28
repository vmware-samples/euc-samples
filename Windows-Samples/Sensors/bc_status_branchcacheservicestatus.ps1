# Returns Branch Cache Client Status details BranchCacheServiceStatus
# Example - Running, Stopped
# Get-BCStatus | Select-Object -ExpandProperty BranchCacheServiceStatus
# Return Type: String
# Execution Context: System
$branchcache = Get-BCStatus
write-output $branchcache.BranchCacheServiceStatus

