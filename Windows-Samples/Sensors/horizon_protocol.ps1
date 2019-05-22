# Returns Horizon protocol information from Horizon Volatile Registry Key
# Return Type: String
# Execution Type: User
$registryKey = Get-ItemProperty -Path "HKCU:\Volatile Environment\1" -ErrorVariable err -ErrorAction SilentlyContinue
$value = $registryKey.ViewClient_Protocol
write-output $value