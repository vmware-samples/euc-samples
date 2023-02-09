# Description: Returns the SMBIOS Version
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$bios = (Get-WmiObject -Class Win32_bios).SMBIOSBIOSVERSION
return $bios
