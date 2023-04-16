# Returns the device's serial number
# Return Type: String
# Execution Context: User
$os=Get-WmiObject Win32_bios -ComputerName $env:computername -ea silentlycontinue
write-output $os.SerialNumber