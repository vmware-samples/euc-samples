# Description: Returns Branch Cache NetworkConfiguration ContentRetrievalFirewallRulesEnabled details. Returns true/false 
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

$branchcache = (Get-BCStatus).NetworkConfiguration.ContentRetrievalFirewallRulesEnabled
return $branchcache

