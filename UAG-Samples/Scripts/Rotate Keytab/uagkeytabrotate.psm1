
$Global:uri = ""
$Global:authheaderobj = $null
$Global:initialized = $false


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Stop" 

$Logfile = "$env:TEMP\uagkeytabrotate-$(get-date -f ddMMyyyy).log"

# Logging Functions
Function LogInfo
{
   Param ([string]$logstring)
   Add-content $Logfile -value "$(Get-Date) |  INFO   | $logstring"
   Write-Host "$(Get-Date) | INFO | $logstring"
}
Function LogSuccess
{
   Param ([string]$logstring)
   Add-content $Logfile -value "$(Get-Date) | SUCCESS | $logstring"
   Write-Host -ForegroundColor Green "$(Get-Date) | SUCCESS | $logstring"
}
Function LogError
{
   Param ([string]$logstring, [string]$errormessage)

   if ($errormessage -ne "") {
     Add-content $Logfile -value "$(Get-Date) |  ERROR  | $errormessage"
     Write-Host -ForegroundColor Red "$(Get-Date) | ERROR | $errormessage"
   }

   Add-content $Logfile -value "$(Get-Date) |  ERROR  | $logstring"
   Write-Host -ForegroundColor Red "$(Get-Date) | ERROR | $logstring"
}
function Get-BaseUrl {
  
   return $Global:uri
}

function CheckUAGInitialization {

  if ( $Global:authheaderobj -eq $null ) {
    LogError "UAG connection not initialized - Use Connect-UAG command"  
    throw
  }
}

function Set-BaseUrl { param( [String]$uri)
   $Global:uri = $uri
}


function Set-AuthHeader { param([Parameter(Mandatory=$true)][string] $username,
      [Parameter(Mandatory=$true)][string] $password)

    $key  = [string]::Format( "{0}:{1}", $username, $password)
    $encodedlogin = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($key))
    $authheader = "Basic " + $encodedlogin
    $Global:authheaderobj = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $Global:authheaderobj.Add("Authorization",$authheader)
}

function Get-AuthHeader {
   return $Global:authheaderobj
}

function New-Keytabfile { param([Parameter(Mandatory=$true)][string] $spn,
      [Parameter(Mandatory=$true)][string] $mapuser, 
      [Parameter(Mandatory=$true)][string] $newpassword,
      [Parameter(Mandatory=$true)][string] $keytabfile) 


  $cmd = [string]::Format("ktpass /princ {0} /mapuser {1} /mapOp set /pass {2} /crypto all /ptype KRB5_NT_PRINCIPAL /out {3} ", $spn, $mapuser, $newpassword, $keytabfile)
  
  Remove-Item $keytabfile -ErrorAction Ignore
  iex $cmd
  
  if (Test-Path $keytabfile) {
     LogSuccess "Keytab file created $keytabfile"
  } else
  {
     LogError "Error creating keytab file, ktpass command fail"
     LogError $cmd
     throw
  }

}

function Connect-UAG { param([Parameter(Mandatory=$true)][string] $username,
      [Parameter(Mandatory=$true)][string] $password, 
      [Parameter(Mandatory=$true)][string] $hostname) 


    Set-AuthHeader $username $password

    Set-BaseUrl ([string]::Format("https://{0}:9443/rest/v1/", $hostname.Trim()))
    $systemapi = (Get-BaseUrl) + "config/system" 

    try {
      LogInfo "Authenticating against VMware Unified Access Gateway"
      $response = Invoke-RestMethod -Uri $systemapi -Headers (Get-AuthHeader) -Method Get 
      
      LogSuccess ("Connected to " + $response.uagName)
      
    } catch {
        LogError "Initialization error $systemapi", $_.Exception.Message
        throw
    }

}

function Get-KeyTabs {
  LogInfo "List KeyTabs"
  return GetAPICall "config/kerberos/keytab"


}

function Import-KeyTab { param([string] $keytabfile, [string] $principalname)


  $base64String = [Convert]::ToBase64String([IO.File]::ReadAllBytes($keytabfile))
  $body = @{
        "keyTab"= $base64String;
	    "principalName"= $principalname; }

  $body = ($body|ConvertTo-Json)

  try
  {
    PutAPICall "config/kerberos/keytab" $body
    LogSuccess "KeyTab uploaded to VMware Unfied Access Gateway"
  } 
  catch {
    LogError "Erro importing KeyTab", $_.Exception.Message

  }

}

function GetAPICall { param([string] $api)

    CheckUAGInitialization

    try {
      $apiurl = (Get-BaseUrl) + $api
      $response = Invoke-RestMethod -Uri $apiurl -Headers (Get-AuthHeader) -Method Get 

    } catch {
      LogError "Erro calling API (Get) $api", $_.Exception.Message
    }
    return $response
}

function PutAPICall ($api, $json) {

    CheckUAGInitialization


    try {

      $apiurl = (Get-BaseUrl) + $api
      LogInfo ("Calling API " + $apiurl)

      Invoke-RestMethod -Method Put -Uri $apiurl -Headers (Get-AuthHeader) -Body $json -ContentType "application/json"


    } catch {
       LogError "Erro calling API (Put) $api", $_.Exception.Message
    }

}

function Update-IIS { param([Parameter(Mandatory=$true)][string] $username,
      [Parameter(Mandatory=$true)][string] $password,
      [Parameter(Mandatory=$false)][string] $serverName,
      [Parameter(Mandatory=$false)][string] $appPoolName = "DefaultAppPool")


#    $scriptBlock = {
#        Import-Module WebAdministration
#        Set-ItemProperty IIS:\AppPools\$appPoolName\ -Name ProcessModel -Value @{userName=$username;password=$password;identityType=3}
#        Start-WebAppPool -Name $appPoolName
#        Get-Item IIS:\AppPools\$appPoolName\
#        iisreset
#        }
#    $testing = Invoke-Command -ComputerName $serverName -ScriptBlock $scriptBlock -Credential $UserCredential -ErrorAction Stop
#    Write-Host "IIS Application Pool State - $($testing.state)"

  Import-Module WebAdministration

  try {
    Set-ItemProperty IIS:\AppPools\$appPoolName\ -Name ProcessModel -Value @{userName=$username;password=$password;identityType=3}
    Start-WebAppPool -Name $appPoolName
    Get-Item IIS:\AppPools\$appPoolName\
    LogSuccess "IIS Application Pool ($appPoolName) updated"
  } catch {
     LogError "Erro updating IIS Application Pool", $_.Exception.Message
  }

  iisreset

}


Export-ModuleMember -Function New-Keytabfile
Export-ModuleMember -Function Connect-UAG
Export-ModuleMember -Function Get-KeyTabs
Export-ModuleMember -Function Import-KeyTab
Export-ModuleMember -Function Update-IIS