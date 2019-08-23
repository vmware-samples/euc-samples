<#
.SYNOPSIS
  Script to update the size of VMware App Volumes Writable Volumes.  Can also be used to view sizes of volumes.
	
.INPUTS
  Parameters Below

.OUTPUTS
  Log file stored in %temp%\expand-wv.log>

.NOTES
  Version:        1.0
  Author:         Chris Halstead - chalstead@vmware.com
  Creation Date:  4/8/2019
  Purpose/Change: Initial script development
  **This script and the App Volumes API is not supported by VMware**
  New sizes won't be reflected until a user logs in and attaches the Writable Volume	
  
.EXAMPLE
 .\Expand-WV.ps1 
        -AppVolumesServerFQDN "avmanager.company.com"
        -AppVolumesDomain "mydomain" 
        -AppVolumesUser "Username" 
        -AppVolumesPassword "SecurePassword" 
        -New_Size_In_MB "40960" 
        -Update_WV_Size "yes" 

    .PARAMETER AppVolumesServerFQDN
    The FQDN of the App Volumes Manager where you want to view / change the Writable Volumes

    .PARAMETER AppVolumesDomain
    Active Directory Domain of the user with Administrative access

    .PARAMETER AppVolumesUser
    Active Directoty User with administrative access

    .PARAMETER AppVolumesPassword
    The password that is used by the user specified in the username parameter

    .PARAMETER New_Size_In_MB
    New size for the writable volumes in Megabytes. Take gigabytes and mutltiply by 1024.

    .PARAMETER Update_WV_Size
    Enter yes to update the sizes.  Type anything else for a list of writable volumes.
#>

[CmdletBinding()]
    Param(

        [Parameter(Mandatory=$True)]
        [string]$AppVolumesServerFQDN,
           
        [Parameter(Mandatory=$True)]
        [string]$AppVolumesDomain,

        [Parameter(Mandatory=$True)]
        [string]$AppVolumesUser,

        [Parameter(Mandatory=$True)]
        [securestring]$AppVolumesPassword,
       
        [Parameter(Mandatory=$true)]
        [string]$New_Size_In_MB,

        [Parameter(Mandatory=$true)]
        [string]$Update_WV_Size

)

#----------------------------------------------------------[Declarations]----------------------------------------------------------
#Log File Info
$sLogPath = $env:TEMP 
$sDomain = $env:USERDOMAIN
$sUser = $env:USERNAME
$sComputer = $env:COMPUTERNAME
$sLogName = "expand-wv.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
$sLogTitle = "Starting Script as $sdomain\$sUser from $scomputer***************"
Add-Content $sLogFile -Value $sLogTitle
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AppVolumesPassword)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$Credentials = @{
  username = "$AppVolumesDomain\$appvolumesuser"
  password = $UnsecurePassword
}

#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function Write-Log {
    [CmdletBinding()]
    Param(
    
    [Parameter(Mandatory=$True)]
    [System.Object]
    $Message

    )
    $Stamp = (Get-Date).toString("MM/dd/yyyy HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    Add-Content $sLogFile -Value $Line
   
    }

Function Connect_AV {
#Connect to App Volumes Manager
Write-Host "Logging on to App Volumes Manager: $appvolumesserverfqdn"
try{$sresult = Invoke-RestMethod -Method Post -Uri "https://$AppVolumesServerFQDN/cv_api/sessions" -Body $Credentials -SessionVariable avsession}
catch {
  Write-Host "An error occurred when logging on $_"
  Write-Log -Message "Error when logging on to AppVolumes Manager: $_"
  Write-Log -Message "Finishing Script*************************************"
  exit 
}

write-Log -Message "Logging on to AppVolumes Manager: $sresult"
write-Log -Message "Enumerating Writable Volumes"
Write-Host "Enumerating Writable Volumes"

#Get Writable Volumes
$sgetwv = Invoke-RestMethod -WebSession $avsession -Method Get -Uri "https://$AppVolumesServerFQDN/cv_api/writables" -ContentType 'application/json'

$json = $sgetwv.datastores.writable_volumes

    foreach ($item in $json)
    {

    If ($Update_WV_Size -eq "YES") {
       #Update Writable Volumes   
      $avid = $item.id
      try{$supdatesize = Invoke-RestMethod -WebSession $avsession -Method Post -Uri "https://$AppVolumesServerFQDN/cv_api/writables/grow?bg=0&size_mb=$New_Size_In_MB&volumes%5B%5D=$avid" -ContentType 'application/json'}
      catch {
        Write-Host "An error occurred when increasing size $_"
      }
      if ($supdatesize.successes.Count -gt 0)
        {Write-Host $supdatesize.successes
        Write-Log -Message $supdatesize.successes
        }
      if ($supdatesize.warnings.Count -gt 0)
        {Write-Host $supdatesize.warnings
        Write-Log -Message $supdatesize.warnings
        }
      if ($supdatesize.errors.Count -gt 0)
        {Write-Host $supdatesize.errors
        Write-Log -Message $supdatesize.errors.Item(0)     
        }
       }   else {
     
        $swvs = $item.name + " " + $item.total_mb + " " + " " + $item.percent_available+ " " + $item.attached

        Write-Host $swvs
        Write-Log -Message $swvs
        }

    }
   

  } 


#-----------------------------------------------------------[Execution]------------------------------------------------------------

Connect_AV
Write-Log -Message "Finishing Script******************************************************"
Write-Host "Finished"