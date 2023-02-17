# Description: Returns True/False if Wifi whether WiFi is present
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

$wireless = Get-WmiObject -class Win32_NetworkAdapter -filter "netconnectionid like 'Wi-Fi%'"
if($wireless)
{Return $true}
else 
{Return $false}

