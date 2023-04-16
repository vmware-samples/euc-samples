# Expand-WV
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