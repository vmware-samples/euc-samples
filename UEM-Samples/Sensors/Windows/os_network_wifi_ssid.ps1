# Description: Returns the currently connected SSID
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$ssid = netsh wlan show interfaces | select-string SSID
if ($ssid -ne $null) {
  $ssid = $ssid[0] | select-string  "SSID"
  return ($ssid -split ":")[-1].Trim()
} else {
  return ""
}
