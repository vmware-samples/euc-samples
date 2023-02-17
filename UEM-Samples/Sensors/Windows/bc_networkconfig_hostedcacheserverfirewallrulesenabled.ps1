# Description: Returns Branch Cache NetworkConfiguration HostedCacheServerFirewallRulesEnabled status. Returns true/false
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

$branchcache = (Get-BCStatus).NetworkConfiguration.HostedCacheServerFirewallRulesEnabled
return $branchcache
