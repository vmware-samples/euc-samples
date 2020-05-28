# Returns Branch Cache Client Status details BranchCacheIsEnabled
# Example - True, False
# Get-BCStatus | Select-Object -ExpandProperty BranchCacheIsEnabled
# Return Type: String
# Execution Context: System
$branchcache = Get-BCStatus
write-output $branchcache.BranchCacheIsEnabled
