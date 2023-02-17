# Description: Returns the device's serial number
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$bios = (Get-WmiObject -Class Win32_bios).SerialNumber
return $bios
