# Description: Returns Branch Cache NetworkConfiguration ContentRetrievalFirewallRulesEnabled details. Returns true/false 
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$branchcache = (Get-BCStatus).NetworkConfiguration.ContentRetrievalFirewallRulesEnabled
return $branchcache

