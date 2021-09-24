# Returns True/False whether the SMBIOS is Present
# Return Type: Boolean
# Execution Context: User
$bios=Get-WmiObject Win32_bios -ComputerName $env:computername -ea silentlycontinue
write-output $bios.SMBIOSPresent