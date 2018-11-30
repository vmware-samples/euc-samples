# Returns build number e.g. 17134
# Return Type: String
# Execution Context: User
$os=Get-WmiObject Win32_OperatingSystem
write-host $os.BuildNumber