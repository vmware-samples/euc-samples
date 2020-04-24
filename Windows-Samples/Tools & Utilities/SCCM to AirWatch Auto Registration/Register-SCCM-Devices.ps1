
<# SCCM to Airwatch Device Registration Script

#Author:  Chris Halstead - chalstead@vmware.com
#May 2018
#Version 2.1

  .SYNOPSIS
    This Powershell script allows you to automatically create device registrations in Airwatch for members of an SCCM collection.
    MUST RUN AS ADMIN
    MUST RUN LOCALLY ON SCCM Site Server

  .DESCRIPTION
    When run, this script will prompt for an SCCM collection name.  The members of this collection and enumberated and Airwatch is checked for exsiting device registrations based on the BIOS serial number.
    If the device does not already exist, the device is registered in Airwatch and associated with the primary user from SCCM.  This allows the Airwatch Agent to be deployed via SCCM or another mechanism and 
    run as the staging user.  

  .EXAMPLE

    .\Register-SCCM-Devices.ps1 `
        -SCCMServer "sccmserver.company.com"
        -SCCMCollectionName "Win10"
        -AirwatchServer "https://airwatch.company.com" `
        -AirWatchAdmin "Username" `
        -AirwatchPW "SecurePassword" `
        -AirwatchAPIKey "iVvHQnSXpX5elicaZPaIlQ8hCe5C/kw21K3glhZ+g/g=" `
        -OrganizationGroupName "chalstead" `

    .PARAMETER SCCMServer
    The name of the SCCM Server 

    .PARAMETER SCCMCollectionName
    The name of the SCCM Collection which contains devices you want to register in Airwatch.

    .PARAMETER AirwatchServer
    Server URL for the AirWatch API Server

    .PARAMETER AirWatchAdmin
    An AirWatch admin account in the tenant that is being queried.  This admin must have the API role at a minimum.

    .PARAMETER AirwatchPW
    The password that is used by the admin specified in the username parameter

    .PARAMETER AirwatchAPIKey
    This is the REST API key that is generated in the AirWatch Console.  You locate this key at All Settings -> Advanced -> API -> REST,
    and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access

    .PARAMETER OrganizationGroupName
    The name of the Organization Group where the device will be regisgtered. 

#>

[CmdletBinding()]
    Param(
   
        [Parameter(Mandatory=$True)]
        [string]$SCCMServer,

        [Parameter(Mandatory=$True)]
        [string]$SCCMCollectionName,

        [Parameter(Mandatory=$True)]
        [string]$AirwatchServer,

        [Parameter(Mandatory=$True)]
        [string]$AirWatchAdmin,

        [Parameter(Mandatory=$True)]
        [string]$AirwatchPW,

        [Parameter(Mandatory=$True)]
        [string]$AirwatchAPIKey,

        [Parameter(Mandatory=$True)]
        [string]$OrganizationGroupName

)

Function Get-OrganizationGroupID {

       Write-Host("Getting Group ID from Group Name")

    $endpointURL = $URL + "/system/groups/search?groupID=" + $organizationGroupName
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
    $totalReturned = $webReturn.Total
    $groupID = -1
    If ($webReturn.Total = 1) {
        $groupID = $webReturn.LocationGroups.Id.Value
        Write-Host("Group ID for " + $organizationGroupName + " = " + $groupID)
    } else {
        Write-host("Group Name: " + $organizationGroupName + " not found")
    }
    
    Return $groupID
}

$URL = $AirwatchServer + "/api"

#Base64 Encode AW Username and Password
$combined = $AirWatchAdmin + ":" + $AirwatchPW
$encoding = [System.Text.Encoding]::ASCII.GetBytes($combined)
$cred = [Convert]::ToBase64String($encoding)

$SCCMSiteCode = ""

#Retrieve the side code of the local SCCM Server
get-WMIObject -ComputerName $SCCMServer -Impersonation 3 -Namespace "root\SMS" -Class "SMS_ProviderLocation" | foreach-object{ 
    if ($_.ProviderForLocalSite -eq $true){$SCCMSiteCode=$_.sitecode} 
    write-host("Local SCCM Site Code: $($SCCMSiteCode)")
} 
  
#Retrieve SCCM collection by name 
$Collection = get-wmiobject -ComputerName  $SCCMServer -Impersonation 3 -NameSpace "ROOT\SMS\site_$SCCMSiteCode" -Class SMS_Collection  | where {$_.Name -eq "$SCCMCollectionName"}  
$SMSMembers = Get-WmiObject -ComputerName $SCCMServer -Impersonation 3 -Namespace  "ROOT\SMS\site_$SCCMSiteCode" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($Collection.CollectionID)' order by name" | select Name

#Check if the Collection Exists
$m =  $SMSMembers | Measure-Object
$membercount = $m.count

if ($Collection -eq $null) 
    {
        #Collection not found.  Exit 
        Write-Host("Collection $SCCMCollectionName not found - Exiting" )
        exit  
    }
else
    {
        if ($m -eq "0")

        {write-host("Collection is empty - Exiting")      
        exit
        }

       Write-Host("Found $membercount members in $SCCMCollectionName")
    }

#Loop through each member of the collection
ForEach ($pc In $SMSMembers)
    {
        #Check for Primary User
        $sprimaryuser = Get-WmiObject -ComputerName $SCCMServer -Impersonation 3 -Namespace  "ROOT\SMS\site_$SCCMSiteCode" -Query "select * from SMS_UserMachineRelationship where ResourceName = '$($pc.name)' and Types = '1'"
        $theprimaryuser = $sprimaryuser.UniqueUserName
        #Retrieve the user information associate with this device        
        $sgetuser = Get-WmiObject -ComputerName $SCCMServer -Impersonation 3 -Namespace  "ROOT\SMS\site_$SCCMSiteCode" -Query "select * from SMS_R_System where name = '$($pc.name)'"
 
        #Use primary user if it exists        
        if($theprimaryuser -eq $null)
        #If primary user does not exist, use last logged on user
        {
        Write-Host("*****************************************************************")      
        $slastuser = $sgetuser.lastlogonusername
        Write-Host("Using Last Logged on User $($slastuser)")
        }

        else {
        $slastuser = $theprimaryuser
        $puarray = $slastuser.split("\")
        $slastuser = $puarray[1]
        Write-Host("*****************************************************************")
        Write-Host("Using Primary User $($slastuser)")
        }
        
        #Get machine details from SCCM
        $sMachine = Get-WmiObject -ComputerName $SCCMServer -Impersonation 3 -Namespace  "ROOT\SMS\site_$SCCMSiteCode" -Query "select SMS_G_System_PC_BIOS.SerialNumber from  SMS_R_System inner join SMS_G_System_PC_BIOS on SMS_G_System_PC_BIOS.ResourceId = SMS_R_System.ResourceId inner join SMS_G_System_SYSTEM on SMS_G_System_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_SYSTEM.Name = '$($pc.name)'"
        #Retrieve the BIOS Serial Number
        $sn = $smachine.SerialNumber
                                    
       
        if ($sn -eq $null)
            {
                
                #Machine is Not an SCCM Client
                Write-Host("$($pc.name) Not an SCCM Client")
                            
            }
            
        else 
            {
                Write-Host("Processing $($pc.name)")                    
                #Process AW device registration - code from Brooks Peppin
                #contruct REST HEADER
                $header = @{
                "Authorization"  = "Basic $cred";
                "aw-tenant-code" = $AirwatchAPIKey;
                "Accept"		 = "application/json";
                "Content-Type"   = "application/json";}
                
                #Get GroupID from Organizational Group Name
                if ($AirwatchGroupID -eq $null)
                {$AirwatchGroupID = Get-OrganizationGroupID($AirwatchGroupID)}

                #Check AW for existing Registration Token
                Write-host "Checking for existing Registration Token"
                $apipath = "/system/users/enrollmenttoken/search?serialnumber="
                $registration = Invoke-RestMethod -Uri "$URL$apipath$sn" -Headers $header
                
                #create new registration if no registration exists
                #Gets userID number as the API requires it
                $apipath = "/system/users/search?username=$slastuser"
                $userid = (Invoke-RestMethod -Uri "$URL$apipath" -Headers $header).Users
                $userid = ($userid | where { ($_.username -like "$slastuser") -and ($_.group -notlike "staging") }).ID.Value #ensures its a real acccount
                $body = @{
                    'LocationGroupID' = "$AirwatchGroupID"; #enroll into Production OG
                    'FriendlyName'    = "$($pc.name)";
                    'Ownership'	      = 'C'; #company owned
                    'SerialNumber'    = "$sn";
                    'PlatformID'	  = '12'; #Windows Desktop platform ID
                        }
                $json = $body | ConvertTo-Json
                If ($registration -eq "")
                {
                    Try
                    {
                        Write-host "No device registration found. Creating new."
                        For ($i = 0; $i -lt $userid.Length; $i++)
                        {
                            $user = $userid[$i]
                            $apipath = "/system/users/$user/registerdevice"
                            Invoke-RestMethod -Uri "$URL$apipath" -Method POST -Headers $header -Body $json
                            write-host("Registration created for $slastuser on device $sn")
                        }
                    }
                    catch
                    {
                        Write-host $_.Exception
                        Write-host "ErrorMessage:" $_.Exception.Message
                        Write-host "ErrorStatus:" $_.Exception.Status
                    }
                }
                else
                {
                    Write-host "Device registration already exists. Checking now for matching registration..."
                    $registereduser = $registration.device.username

                    If ($registereduser -eq $slastuser)
                    {
                        
                        Write-Host "Device $sn is already registered to $registereduser"
                    }
                    else
                    {
                        Write-Host "Device $sn is registered to $registereduser"
                        Write-Host "Registration does not match. Updating record."
                        $apipath = "/system/users/$userid/registerdevice"
                        Invoke-RestMethod -Uri "$URL$apipath" -Method POST -Headers $header -Body $json
                        
                    }
                }    


}

Write-Host("Processing Complete")
Write-Host("*****************************************************************")
}


                
                     

            
