# Description: Returns Time Zone
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$tz = (Get-TimeZone).StandardName
return $tz
