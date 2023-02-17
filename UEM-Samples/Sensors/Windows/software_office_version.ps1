# Description: Returns the MS Office (O365) version
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$officeversion = Get-ItemPropertyValue -Path "Registry::HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -Name "ClientVersionToReport" -ErrorAction SilentlyContinue
return $officeversion

