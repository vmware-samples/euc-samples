# Returns Branch Cache Client Configuration details CurrentClientMode
# Example - True, False
# Get-BCStatus | Select-Object -ExpandProperty ClientConfiguration | Select-Object -ExpandProperty HostedCacheDiscoveryEnabled
# Return Type: String
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty ClientConfiguration
write-output $branchcache.HostedCacheDiscoveryEnabled
