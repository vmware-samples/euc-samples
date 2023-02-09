# Description: Returns Branch Cache NetworkConfiguration HostedCacheServerFirewallRulesEnabled status. Returns true/false
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$branchcache = (Get-BCStatus).NetworkConfiguration.HostedCacheServerFirewallRulesEnabled
return $branchcache
