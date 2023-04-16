# Returns OS Architecture (32-bit or 64-bit)
# Return Type: String
# Execution Context: User
$os=(Get-WmiObject Win32_OperatingSystem)
write-output $os.OSArchitecture