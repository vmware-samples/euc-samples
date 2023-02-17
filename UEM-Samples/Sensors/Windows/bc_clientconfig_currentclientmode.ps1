# Description: Returns Branch Cache Client Configuration details CurrentClientMode. Returns - Enabled, Disabled
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$branchcache = (Get-BCStatus).ClientConfiguration.CurrentClientMode
return $branchcache
