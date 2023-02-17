# Description: Returns device hostname
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$hostname = $env:COMPUTERNAME
return $hostname

