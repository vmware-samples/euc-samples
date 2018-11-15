# Returns the SMBIOS Version
# Return Type: String
# Execution Context: User
$bios=Get-WmiObject Win32_bios -ComputerName $env:computername -ea silentlycontinue
write-output $bios.SMBIOSBIOSVersion