# Description: Returns device hostname
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$hostname = $env:COMPUTERNAME
return $hostname

