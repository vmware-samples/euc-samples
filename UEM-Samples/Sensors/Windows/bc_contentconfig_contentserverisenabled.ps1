# Returns Branch Cache ContentServerConfiguration details 
# Example - True,False
# Get-BCStatus | Select-Object -ExpandProperty ContentServerConfiguration | Select-Object -ExpandProperty ContentServerIsEnabled
# Return Type: String
# Execution Context: System
$branchcache = Get-BCStatus | Select-Object -ExpandProperty ContentServerConfiguration
write-output $branchcache.ContentServerIsEnabled
