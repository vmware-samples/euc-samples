# Description: Returns Branch Cache NetworkConfiguration PeerDiscoveryFirewallRulesEnabled status. Returns true/false
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

$branchcache = (Get-BCStatus).NetworkConfiguration.PeerDiscoveryFirewallRulesEnabled
return $branchcache
