# Description: Returns Horizon protocol information from Horizon Volatile Registry Key
# Execution Context: USER
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$registryKey = Get-ItemProperty -Path "HKCU:\Volatile Environment\1" -ErrorVariable err -ErrorAction SilentlyContinue
$value = $registryKey.ViewClient_Protocol
if ($value){
Return $value
}
else {Return "Horizon protocol information not available"}

