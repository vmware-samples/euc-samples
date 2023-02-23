# Description: Returns build number e.g. 19041
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: INTEGER

[int]$BuildNumber=(Get-WmiObject Win32_OperatingSystem).Buildnumber
return $BuildNumber

