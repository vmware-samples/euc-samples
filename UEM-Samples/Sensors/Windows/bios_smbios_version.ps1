# Description: Returns the SMBIOS Version
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$bios = (Get-WmiObject -Class Win32_bios).SMBIOSBIOSVERSION
return $bios
