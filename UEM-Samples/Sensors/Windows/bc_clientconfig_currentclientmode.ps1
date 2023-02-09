# Description: Returns Branch Cache Client Configuration details CurrentClientMode. Returns - Enabled, Disabled
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$branchcache = (Get-BCStatus).ClientConfiguration.CurrentClientMode
return $branchcache
