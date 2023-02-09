# Description: Return WS1 Device UUID
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$WS1_UDID = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\MDMDeviceID\" -Name "DeviceClientId" -ErrorAction SilentlyContinue
return $WS1_UDID

