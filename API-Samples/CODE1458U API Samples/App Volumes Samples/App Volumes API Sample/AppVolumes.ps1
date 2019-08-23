<#
.SYNOPSIS
  Sample script for VMware App Volumes REST API
	
.NOTES
  Version:        1.0
  Author:         Chris Halstead - chalstead@vmware.com
  Creation Date:  8/21/2019
  Purpose/Change: Initial script development
  
#>


#----------------------------------------------------------[Declarations]----------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function LogintoAppVolumes {

#Get Values from User
$script:AppVolServer = Read-Host -Prompt 'Enter the App Volumes Manager Name'
$Username = Read-Host -Prompt 'Enter the Username'
$Password = Read-Host -Prompt 'Enter the Password' -AsSecureString
$domain = Read-Host -Prompt 'Enter the Domain'

#Convert the Password
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

#Construct JSON to pass to login endpoint
$Credentials = '{"username":"' + $username + '","password":"' + $unsecurepassword + '","domain":"' + $domain + '"}'

#Login to AppVolumes
try {
    
  $sresult = Invoke-RestMethod -Method Post -Uri "https://$appvolserver/cv_api/sessions" -Body $Credentials -ContentType "application/json" -SessionVariable avsession  

}

catch {
  Write-Host "An error occurred when logging on $_"
  break
}

#Logged In
$sresult | Format-List
write-host "Successfully Logged In"

#Save the AV session state to a varable - contains cookies with session information
$script:AVSession = $avsession

  } 

Function ListAppStacks {
    
    if ([string]::IsNullOrEmpty($AVSession))
    {
       write-host "You are not logged into App Volumes"
        break   
       
    }

   
    try {
        
        $sresult = Invoke-RestMethod -Method Get -Uri "https://$appvolserver/cv_api/appstacks" -ContentType "application/json" -WebSession $avSession 
    }
    
    catch {
      Write-Host "An error occurred when getting AppStacks $_"
      break 
    }
    
write-host "List of AppStacks on: "$appvolserver
$sresult | Format-Table -autosize -Property Id,Name,Status,created_at_human
    
      } 
Function AppStackDetails {
   
        if ([string]::IsNullOrEmpty($AVSession))
        {
           write-host "You are not logged into App Volumes"
            break   
           
        }

        $asid = Read-Host -Prompt 'Enter the AppStack ID for More Details'
           
        try {
            
            $sresult = Invoke-RestMethod -Method Get -Uri "https://$appvolserver/cv_api/appstacks/$asid" -ContentType "application/json" -WebSession $AVSession
        }
        
        catch {
          Write-Host "An error occurred when logging on $_"
        break 
        }
        
        
      $sresult.AppStack | Format-Table -AutoSize -Property Name,Status,Size_mb,Assigments_Total
       
          } 

Function AppStackApps {
   
  if ([string]::IsNullOrEmpty($AVSession))
      {
        write-host "You are not logged into App Volumes"
        break   
               
      }
    
      $asid = Read-Host -Prompt 'Enter the AppStack ID for the list of Applications'
               
            try {
                
                $sresult = Invoke-RestMethod -Method Get -Uri "https://$appvolserver/cv_api/appstacks/$asid/applications" -ContentType "application/json" -WebSession $AVSession
            }
            
            catch {
              Write-Host "An error occurred when logging on $_"
              break 
            }
            
            
          $sresult.applications | Format-Table -AutoSize -Property Name,version,publisher

           
              } 

Function Writables {
   
  if ([string]::IsNullOrEmpty($AVSession))
        {
          write-host "You are not logged into App Volumes"
          break   
                             
        }
                  
                            
    try {                    
      $sresult = Invoke-RestMethod -Method Get -Uri "https://$appvolserver/cv_api/writables" -ContentType "application/json" -WebSession $AVSession
        }
                          
        catch {
              Write-Host "An error occurred when logging on $_"
              break 
              }
                     
    $sresult.datastores.writable_volumes | Format-Table -AutoSize -Property @{Name = 'Name'; Expression = {$_.name}},@{Name = 'Owner UPN'; Expression = {$_.owner_upn}},`
    @{Name = 'Type'; Expression = {$_.owner_type}},@{Name = 'Size in MB'; Expression = {$_.Size_mb}},@{Name = '% Available'; Expression = {$_.percent_available}},`
    @{Name = 'Last Mounted'; Expression = {$_.mounted_at_human}},@{Name = 'Attached?'; Expression = {$_.attached}},@{Name = 'Enabled?'; Expression = {$_.Status}}
            
                         
} 

Function Activity_Log {
   
  if ([string]::IsNullOrEmpty($AVSession))
        {
          write-host "You are not logged into App Volumes"
          break   
                             
        }
                  
                            
    try {                    
      $sresult = Invoke-RestMethod -Method Get -Uri "https://$appvolserver/cv_api/system_messages" -ContentType "application/json" -WebSession $AVSession
        }
                          
        catch {
              Write-Host "An error occurred when logging on $_"
              break 
              }
                     
    $sresult.allmessages.system_messages | Format-list -Property Message,Event_time_human
             
                         
} 

Function Get_Online {
   
  if ([string]::IsNullOrEmpty($AVSession))
        {
          write-host "You are not logged into App Volumes"
          break   
                             
        }
                  
                            
    try {                    
      $sresult = Invoke-RestMethod -Method Get -Uri "https://$appvolserver/cv_api/online_entities" -ContentType "application/json" -WebSession $AVSession
        }
                          
        catch {
              Write-Host "An error occurred when logging on $_"
              break 
              }
                     
    $sresult.online.records | Format-Table -AutoSize -Property agent_status,entity_name,entity_type,duration_words,details
             
                         
} 

function Show-Menu
  {
    param (
          [string]$Title = 'VMware App Volumes API Menu'
          )
       Clear-Host
       Write-Host "================ $Title ================"
       Write-Host "Press '1' to Login to App Volumes"
       Write-Host "Press '2' for a List of AppStacks"
       Write-Host "Press '3' for AppStack Details"
       Write-Host "Press '4' for a List of Applications in an AppStack"
       Write-Host "Press '5' for Writable Volumes"
       Write-Host "Press '6' to list Applications in an AppStack"
       Write-Host "Press '7' for the Activity Log"
       Write-Host "Press '8' for Online Entities"
       Write-Host "Press 'Q' to quit."
         }

do

 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    
    '1' {  

         LogintoAppVolumes
    } 
    
    '2' {
   
         ListAppStacks

    }
    
    '3' {
       
         AppStackDetails
      
    }
'4' {
       
    AppStackApps
     
    }

'5' {
       
    Writables
 
}
'6' {
  
 AppStackApps

}

'7' {
  
Activity_Log
 
 }

 '8' {
  
  Get_Online

}

    }
    pause
 }
 until ($selection -eq 'q')


