# Returns Branch Cache HostedCacheServerConfiguration details 
# Example - Domain,
# Get-BCStatus | Select-Object -ExpandProperty HostedCacheServerConfiguration | Select-Object -ExpandProperty ClientAuthenticationMode
# Return Type: String
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty HostedCacheServerConfiguration
write-output $branchcache.ClientAuthenticationMode
