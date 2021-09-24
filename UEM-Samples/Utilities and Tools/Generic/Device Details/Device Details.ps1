<#
.SYNOPSIS
Sample script for VMware Workspace ONE UEM REST API

.NOTES
  Version:        1.0
  Author:         Chris Halstead - chalstead@vmware.com
  Creation Date:  8/21/2019
  Purpose/Change: Initial script development
  
#>

#----------------------------------------------------------[Declarations]----------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function SearchForDevices {

if ([string]::IsNullOrEmpty($wsoserver))
  {
    $script:WSOServer = Read-Host -Prompt 'Enter the Workspace ONE UEM Server Name'
    
  }
 if ([string]::IsNullOrEmpty($header))
  {
    $Username = Read-Host -Prompt 'Enter the Username'
    $Password = Read-Host -Prompt 'Enter the Password' -AsSecureString
    $apikey = Read-Host -Prompt 'Enter the API Key'

    #Convert the Password
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    #Base64 Encode AW Username and Password
    $combined = $Username + ":" + $UnsecurePassword
    $encoding = [System.Text.Encoding]::ASCII.GetBytes($combined)
    $cred = [Convert]::ToBase64String($encoding)

    $script:header = @{
    "Authorization"  = "Basic $cred";
    "aw-tenant-code" = $apikey;
    "Accept"		 = "application/json;version=2";
    "Content-Type"   = "application/json";}
  }

$user = Read-Host -Prompt 'Enter a user name to show devices'

try {
    
  $sresult = Invoke-RestMethod -Method Get -Uri "https://$wsoserver/api/mdm/devices/search?user=$user" -ContentType "application/json" -Header $header

}

catch {
  Write-Host "An error occurred when logging on $_"
  break
}

write-host $sresult.Devices.Count "devices found"

$sresult.devices | format-table -Property @{Name = 'Username'; Expression = {$_.username}},@{Name = 'Platform'; Expression = {$_.platform}},@{Name = 'Enrollment Status'; Expression = {$_.enrollmentstatus}}`
,@{Name = 'ID'; Expression = {$_.id.value}}

} 






Function DeviceDetails {

  if ([string]::IsNullOrEmpty($wsoserver))
    {
      $script:WSOServer = Read-Host -Prompt 'Enter the Workspace ONE UEM Server Name'
      
    }
   if ([string]::IsNullOrEmpty($header))
    {
      $Username = Read-Host -Prompt 'Enter the Username'
      $Password = Read-Host -Prompt 'Enter the Password' -AsSecureString
      $apikey = Read-Host -Prompt 'Enter the API Key'
  
      #Convert the Password
      $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
      $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  
      #Base64 Encode AW Username and Password
      $combined = $Username + ":" + $UnsecurePassword
      $encoding = [System.Text.Encoding]::ASCII.GetBytes($combined)
      $cred = [Convert]::ToBase64String($encoding)
  
      $script:header = @{
      "Authorization"  = "Basic $cred";
      "aw-tenant-code" = $apikey;
      "Accept"		 = "application/json";
      "Content-Type"   = "application/json";}
    }
  
  $id = Read-Host -Prompt 'Enter a device id'
  
  try {
      
    $sresult = Invoke-RestMethod -Method Get -Uri "https://$wsoserver/API/mdm/devices/$id" -ContentType "application/json" -Header $header
  
  }
  
  catch {
    Write-Host "An error occurred when logging on $_"
    break
  }
  
if ($sresult.total -eq 0) {

  Write-Host "No Results"
  break

}

  #Logged In
  $sresult | Format-list
  
  } 
  
  

function Show-Menu
  {
    param (
          [string]$Title = 'VMware Workspace ONE UEM API Menu'
          )
       Clear-Host
       Write-Host "================ $Title ================"
       Write-Host "Press '1' to show devices by username"
       Write-Host "Press '2' for device details"
       Write-Host "Press 'Q' to quit."
         }

do

 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    
    '1' {  

         SearchForDevices
    } 
    
    '2' {
   
         DeviceDetails

    }
    
    }
    pause
 }
 until ($selection -eq 'q')

