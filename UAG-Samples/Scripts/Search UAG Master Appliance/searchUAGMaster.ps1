
param([Parameter(Mandatory=$true)][string] $username,
      [Parameter(Mandatory=$true)][string] $password, 
      [Parameter(Mandatory=$true)][string[]] $UAGAppliancesFQDNorIP)


$userpass  = $username + “:” + $password
$bytes= [System.Text.Encoding]::UTF8.GetBytes($userpass)
$encodedlogin=[Convert]::ToBase64String($bytes)
$authheader = "Basic " + $encodedlogin
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization",$authheader)

Write-Host "Search for the Unified Access Gateway appliance in Master state"
Write-Host ""

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$i = 0
foreach ($element in $UAGAppliancesFQDNorIP) {

   if ($element) {
       $uri = "https://" + $element.Trim() + ":9443/rest/v1/config/loadbalancer/state"
       
       $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get 

       if ($response -eq "Master" ) {
          Write-Host "$element is the MASTER appliance" -ForegroundColor Blue -BackgroundColor White
          $i++
       } else {
          Write-Host "$element is in $response state"    
       }
    }
}

Write-Host ""
Write-Host "Found $i Unified Access Gateway appliance in Master state"



