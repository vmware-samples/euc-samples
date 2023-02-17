# Description: Returns Branch Cache ContentServerConfiguration details. Returns - True/False
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

$branchcache = (Get-BCStatus).ContentServerConfiguration.ContentServerIsEnabled
return $branchcache

