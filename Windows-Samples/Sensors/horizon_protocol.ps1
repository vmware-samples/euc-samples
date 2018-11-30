# Returns Horizon protocol information from Horizon Volatile Registry Key
# Return Type: String
# Execution Type: User
$registryKey = Get-ItemProperty -Path "HKCU:\Volatile Environment\1"
$value = $RegistryKey.ViewClient_Protocol
write-output $value