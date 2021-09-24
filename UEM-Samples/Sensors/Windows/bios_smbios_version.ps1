# Returns the SMBIOS Version
# Return Type: String
# Execution Context: System
$ver = (Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVERSION
return $ver