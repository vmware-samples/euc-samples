# Description: Returns True/False whether the SMBIOS is Present
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$bios = (Get-WmiObject -Class Win32_bios).SMBIOSPresent
return $bios
