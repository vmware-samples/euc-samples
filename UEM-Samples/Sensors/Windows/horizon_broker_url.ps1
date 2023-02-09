# Description: Returns Horizon Broker URL from Horizon Volatile Registry Key
# Execution Context: USER
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$registryKey = Get-ItemProperty -Path "HKCU:\Volatile Environment\1" -ErrorVariable err -ErrorAction SilentlyContinue
$value = $RegistryKey.ViewClient_Broker_URL
if ($value){
Return $value
}
else
{Return "Horizon Broker URL not available"}

