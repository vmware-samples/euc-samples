# Description: Returns Time Zone
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$tz = (Get-TimeZone).StandardName
return $tz
