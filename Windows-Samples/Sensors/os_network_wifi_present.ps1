# Returns True/False if Wifi is present or not
# Return Type: Boolean
# Execution Context: User
$wireless = Get-WmiObject -class Win32_NetworkAdapter -filter "netconnectionid like 'Wi-Fi%'"
if($wireless){echo $true}
else {echo $false}