
<# Tag SCCM Devices in Airwatch with SCCM Collection Name

#Author:  Chris Halstead - chalstead@vmware.com
#February 2018
#Version 1.1

  .SYNOPSIS
    This Powershell script allows you to automatically create tags in Airwatch for SCCM Collections and tag devices which exist in Airwatch with that collection name.
    MUST RUN AS ADMIN
    MUST RUN ON SCCM Site Server

  .DESCRIPTION
   This script connects to SCCM via WMI and retrieves Device collections and members. The script will create a Tag in the specified Airwatch environment for a specified colllection
   or all Device collections.  Each memeber of the collection is queryied in Airwatch and if the devices exists, the tag will be applied to the device.  This allows correlation between SCCM
   and Airwatch for co-existance.  Devices can still be grouped with SCCM collections, but managed through Airwatch for tasks such as software distribution.  

  .EXAMPLE

    .\Tag-SCCM-Collections.ps1 `
        -SCCMCollectionName "All"
        -AirwatchServer "https://airwatch.company.com" `
        -AirwatchUser "Username" `
        -AirwatchPW "SecurePassword" `
        -AirwatchAPIKey "iVvHQnSXpX5elicaZPaIlQ8hCe5C/kw21K3glhZ+g/g=" `
        -AWOrganizationGroupName "myogname" `

    .PARAMETER SCCMCollectionName
    The name of the SCCM Collection which you want to create a tag for.  Devices in the colelctions which exist in Airwatch will be tagged with the collection name. 
    Input All for all Device collections in SCCM.

    .PARAMETER AirwatchServer
    Server URL for the AirWatch API Server

    .PARAMETER AirwatchUser
    An AirWatch account in the tenant is being queried.  This user must have the API role at a minimum.

    .PARAMETER AirwatchPW
    The password that is used by the user specified in the username parameter

    .PARAMETER AirwatchAPIKey
    This is the REST API key that is generated in the AirWatch Console.  You locate this key at All Settings -> Advanced -> API -> REST,
    and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access

    .PARAMETER AWOrganizationGroupName
    The name of the Organization Group where the device will be registered. 

#>


[CmdletBinding()]
    Param(

        [Parameter(Mandatory=$True)]
        [string]$SCCMCollectionName,

        [Parameter(Mandatory=$True)]
        [string]$AirwatchServer,

        [Parameter(Mandatory=$True)]
        [string]$AirwatchUser,

        [Parameter(Mandatory=$True)]
        [string]$AirwatchPW,

        [Parameter(Mandatory=$True)]
        [string]$AirwatchAPIKey,

        [Parameter(Mandatory=$True)]
        [string]$AWOrganizationGroupName

)

Function Get-OrganizationGroupID {

Write-Host("Getting Group ID from Group Name")

 $endpointURL = $URL + "/system/groups/search?groupID=" + $AWorganizationGroupName
 $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
 $totalReturned = $webReturn.Total
 $groupID = -1
 If ($webReturn.Total = 1) {
     $groupID = $webReturn.LocationGroups.Id.Value
     Write-Host("Group ID for " + $AWorganizationGroupName + " = " + $groupID)
 } else {
     Write-host("Group Name: " + $AWorganizationGroupName + " not found")
 }
 
 Return $groupID
}

$URL = $AirwatchServer + "/api"

#Base64 Encode AW Username and Password

$combined = $AirwatchUser + ":" + $AirwatchPW
$encoding = [System.Text.Encoding]::ASCII.GetBytes($combined)
$cred = [Convert]::ToBase64String($encoding)

$header = @{
    "Authorization"  = "Basic $cred";
    "aw-tenant-code" = $AirwatchAPIKey;
    "Accept"		 = "application/json";
    "Content-Type"   = "application/json";}

$SCCMSiteCode = ""

#Retrieve the side code of the local SCCM Server
get-WMIObject -ComputerName "." -Namespace "root\SMS" -Class "SMS_ProviderLocation" | foreach-object{ 
    if ($_.ProviderForLocalSite -eq $true){$SCCMSiteCode=$_.sitecode} 
    write-host("Local SCCM Site Code: $($SCCMSiteCode)")
} 

#Retrieve SCCM collection by name 

if ($SCCMCollectionName -eq "All")

{$AllCollections = get-wmiobject -NameSpace "ROOT\SMS\site_$SCCMSiteCode" -Query "select * from SMS_Collection where CollectionType = '2'"}

else { 

$AllCollections = get-wmiobject -NameSpace "ROOT\SMS\site_$SCCMSiteCode" -Query "select * from SMS_Collection where Name = '$($SCCMCollectionName)' and CollectionType = '2'"

}

if ($AllCollections -eq $null)
{
  #Collection not found.  Exit 
  Write-Host("Collection $SCCMCollectionName not found - Exiting" )
  exit  
}

foreach ($thecollection in $AllCollections)

{
       #Get GroupID from Organizational Group Name
       if ($AirwatchGroupID -eq $null)
       {$AirwatchGroupID = Get-OrganizationGroupID($AWOrganizationGroupName)} 
       
        $collname = $thecollection.name
        write-host("Processing: $($thecollection.name)")

        $endpointURL = $url + "/mdm/tags/search?organizationgroupid=" + $AirwatchGroupID
        $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $header
        $supervisedTagExists = $false
        $supervisedTagID = -1
        Write-Verbose("Web Return: " + $webReturn.Total)
        If ([int]$webReturn.Total -gt 0) {
            foreach($currentTag in $webReturn.Tags) {
                if ($currentTag.TagName -eq $($collname))
                {
                    $supervisedTagID = $currentTag.Id.Value
                    $supervisedTagExists = $True
                    Write-Host("Found tag: " + $currentTag.TagName)
                }
            }
        }
    
        If ($supervisedTagExists -ne $True) {
     
            Write-host("Tag Not Found - creating")
            
            $quoteCharacter = [char]34
            $tagJSON = "{ " + $quoteCharacter + "TagAvatar" + $quoteCharacter + " : " + $quoteCharacter + $quoteCharacter + ", "
            $tagJSON = $tagJSON + $quoteCharacter + "TagName" + $quoteCharacter + " : " + $quoteCharacter + "$($thecollection.name)" + $quoteCharacter + ", "
            $tagJSON = $tagJSON + $quoteCharacter + "TagType" + $quoteCharacter + " : " + "1" + ", "
            $tagJSON = $tagJSON + $quoteCharacter + "LocationGroupId" + $quoteCharacter + " : " + $AirwatchGroupID + ", "
            $tagJSON = $tagJSON + $quoteCharacter + "id" + $quoteCharacter + " : " + "1" + " }"
          
            #write-host($tagJSON)

            $apipath = "/mdm/tags/addtag"
            $tagid = Invoke-RestMethod -Uri "$URL$apipath" -Method POST -Headers $header -Body $tagjson
            
            write-host($($tagid.value))

            $supervisedTagID = $($tagid.value)
          
        }  
    
  
$SMSMembers = Get-WmiObject -Namespace  "ROOT\SMS\site_$SCCMSiteCode" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($theCollection.CollectionID)' order by name" | select Name


        #Loop through each member of the collection
        ForEach ($pc In $SMSMembers)
            {
              
                #Get machine details from SCCM
                $sMachine = Get-WmiObject -Namespace  "ROOT\SMS\site_$SCCMSiteCode" -Query "select SMS_G_System_PC_BIOS.SerialNumber from  SMS_R_System inner join SMS_G_System_PC_BIOS on SMS_G_System_PC_BIOS.ResourceId = SMS_R_System.ResourceId inner join SMS_G_System_SYSTEM on SMS_G_System_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_SYSTEM.Name = '$($pc.name)'"
                #Retrieve the BIOS Serial Number
                $sn = $smachine.SerialNumber
                                         
            
                if ($sn -eq $null)
                    {
                        
                        #Write-Host("$($pc.name) Not an SCCM Client")
                                            
                    }
                    
                else 
                    {
                                                                        
                        Write-Host("Processing $($pc.name)")                    
                      
                        Write-host "Checking for existing Registration Token"

                        $apipath = "/mdm/devices?searchBy=SerialNumber&id=$($sn)"

                        $registration = Invoke-RestMethod -Uri "$URL$apipath" -Headers $header
                        
                        If ($registration -eq $null)
                      
                        {}
                     
                        else
                        {
                             $quoteCharacter = [char]34                  
                             $theregistration = $registration.Id.Value
                             Write-Host("Device $($pc.name) is found in AW - update Tags")

                             $addTagJSON = "{ " + $quoteCharacter + "BulkValues" + $quoteCharacter + " : { " + $quoteCharacter + "Value" + $quoteCharacter + " : [ "

                             $addTagJSON = $addTagJSON + $quoteCharacter + $($theregistration) + $quoteCharacter

                             $addTagJSON = $addTagJSON + " ] } }"
                            
                             $endpointURL = $url + "/mdm/tags/" + $($supervisedTagID) + "/adddevices"

                            Invoke-RestMethod -Method Post -Uri $endpointURL -Headers $header -Body $addTagJSON           
                          
                        }    

                    }

                    
}

Write-Host("Processing Complete")

}



                
                     

            
