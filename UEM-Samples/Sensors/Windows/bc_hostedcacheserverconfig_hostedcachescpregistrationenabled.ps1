# Returns Branch Cache HostedCacheServerConfiguration details 
# Example - True,False
# Get-BCStatus | Select-Object -ExpandProperty HostedCacheServerConfiguration | Select-Object -ExpandProperty HostedCacheScpRegistrationEnabled
# Return Type: String
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty HostedCacheServerConfiguration
write-output $branchcache.HostedCacheScpRegistrationEnabled
