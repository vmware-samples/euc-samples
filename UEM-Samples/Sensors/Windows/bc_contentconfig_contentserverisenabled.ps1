# Description: Returns Branch Cache ContentServerConfiguration details. Returns - True/False
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$branchcache = (Get-BCStatus).ContentServerConfiguration.ContentServerIsEnabled
return $branchcache

