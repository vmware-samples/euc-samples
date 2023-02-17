# Description: Return Site Name based on IP Subnet Octet + IP Default GW
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

<#
  Get Site Name based on IP Subnet Octet + IP Default GW
  Uses a 3d array. Each dimension (line) must align with value in preceeding line.
  Dimension 1 = IP Octet
  Dimension 2 = Default GW
  Dimension 3 = return value / location
  For example, subnet 192.168.1 has default GW of 192.168.1.1 and is in Adelaide. Each is in the same position, on the relevant line
  
  Return value is the third dimension (line) in the localsubnets array, and should be used to find in WS1 Intelligence Automation and Tag a device. 
  The Tag would be a filter in a SmartGroup which is used to assign a Profile/Application.
#>

$localsubnets = @(
  ('192.168.1','192.168.2','10.200.20','10.200.22'),
  ('192.168.1.1','192.168.2.1','10.200.20.254','10.200.22.254'),
  ('Sydney','Adelaide','Melbourne','Brisbane')
)

#Get local IP Address
$NIC = Get-WmiObject win32_networkadapterconfiguration | Where-Object {$_.ipenabled -eq 'true' -and $_.Description -notlike 'VMware*' -and $_.Description -notlike 'Hyper-V*'}
$CurrentIP = ($NIC.IPAddress[0])
#Get local subnet address
$CurrentIPOctet = $CurrentIP.Substring(0, $CurrentIP.lastIndexOf('.'))
$DefaultGW = ($NIC.DefaultIPGateway)

if($localsubnets[0].Contains($CurrentIPOctet)){
  $index = [array]::indexof($localsubnets[0],$CurrentIPOctet)
  if($localsubnets[1] -Contains $DefaultGW){
    return $localsubnets[2][$index]
  } else { return 'unmanaged'}
}
