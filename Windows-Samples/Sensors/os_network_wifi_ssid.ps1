# Returns the currently connected SSID
# Execution Context: User

$ssid = netsh wlan show interfaces | select-string SSID
if ($ssid -ne $null) {
  $ssid = $ssid[0] | select-string  ‘SSID’
  Write-Output ($ssid -split “:”)[-1].Trim()
} else {
  Write-Output “”
}