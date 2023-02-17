# Description: Returns build number e.g. 190454
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$BuildNumber=(Get-WmiObject Win32_OperatingSystem).Buildnumber
return $BuildNumber

