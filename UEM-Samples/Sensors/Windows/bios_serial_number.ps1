# Description: Returns the device's serial number
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$bios = (Get-WmiObject -Class Win32_bios).SerialNumber
return $bios
