# Returns Branch Cache Client Configuration details HostedCacheServerList
# Example - Servers of the hosted Cache mode.
# Get-BCStatus | Select-Object -ExpandProperty ClientConfiguration | Select-Object -ExpandProperty HostedCacheServerList
# Return Type: String
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty ClientConfiguration
write-output $branchcache.HostedCacheServerList

