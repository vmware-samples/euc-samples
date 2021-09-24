# Returns Branch Cache Client Status details BranchCacheServiceStartType
# Example - Manual, Automatic
# Get-BCStatus | Select-Object -ExpandProperty BranchCacheServiceStartType
# Return Type: String
# Execution Context: System
$branchcache = Get-BCStatus
write-output $branchcache.BranchCacheServiceStartType


