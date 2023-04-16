
# LGPO Upload to WS1 UEM Console

## Overview
- **Author**: Ameya Jambavalikar
- **Email**: ajambavalikar@vmware.com
- **Date Created**: 08/31/2018
- **Tested on AirWatch 9.7.0.0**: Completed

## SYNOPSIS
This Powershell script allows you to download LGPO.exe from the MSFT website and upload it as a Managed App to a specified WS1 Organization Group. 

**Requirements**
- Must download supporting file Deploy-LGPO.ps1 and save it in the same location that Download-LGPO.ps1 will be run from.
- Must have access to an AirWatch Admin Account that can authenticate to the APIs with Basic auth (Certificates currently not supported)
- Must have the integer value of Organization Group ID, and API Tenant key for that OG
- Full API automation support only available on AirWatch 9.2.3.0 and newer 

        
## DESCRIPTION
When run, this script will download LGPO.exe into a local folder (C:\Temp\Downloads), repackage LGPO.exe and Deploy-LGPO.ps1 into LGPO-package.zip, and then upload LGPO-package.zip to the WS1 UEM console. It will also offer a reminder to admins to login to the UEM console and assign the application to relevant smart groups.

	
## Modifications Required
You will need to supply your AirWatch Admin credentials, including the AirWatch API Key, when prompted. 

## Known Issues
The task to upload LGPO-package.zip to the AirWatch Console will fail versions of AirWatch prior to 9.2.3.0.  See the EXAMPLE section for a full walkthrough of both processes.
	
## EXAMPLE

    .\Download-LGPO.ps1 `
        -awServer "https://mondecorp.ssdevrd.com" `
        -awUsername "tkent" `
        -awPassword "SecurePassword" `
        -awTenantAPIKey "iVvHQnSXpX5elicaZPaIlQ8hCe5C/kw21K3glhZ+g/g=" `
        -awGroupID "652" `
        -Verbose

**AirWatch 9.2.3.0 and Newer:**

1. Run the Download-LGPO.ps1 script
2. Navigate to the AirWatch Console and find the uploaded LGPO-package app under Apps & Books > Applications > Native.  Click Assign by the Application and add your target devices and/or users.

**AirWatch 9.2.2.X and Prior:**

1. Run the Download-LGPO.ps1 script
2. The process to upload LGPO-Package.zip to the AirWatch Console will fail.
4. Navigate to the C:\Temp\Downloads.  LGPO-Package.zip file will be generated.  You will need this .zip file in the next step.
4. Navigate to the AirWatch Console > Apps & Books > Applications > Native.  Click Add Application.
	1. For the Application File, provide the .zip from your Project Root Folder > GPO Uploads.
	2. When editing the Application, provide the following details:
		1. **Files:**
			1. Uninstall Command: LGPO.exe
		1. **Deployment Options:**
			1. Install Context: Device
			2. Install Command: powershell -executionpolicy bypass -File ./Deploy-LGPO.ps1			
			3. Admin Privileges: Yes
			4. Installer Reboot Exit Code: 0
			5. Installer Success Exit Code: 0
			6. Identify Application By: DefiningCriteria
			7. Criteria Type: File Exists
			8. File Path: "$env:ProgramData\AirWatch\LGPO\LGPO.exe"			
			9. Success Exit Code: 0
        
## Parameters

**awServer**

Server URL for the AirWatch API Server

**awUsername**

The username of an AirWatch account being used in the target AirWatch server.  This user must have a role that allows API access.
  
**awPassword**

The password of the AirWatch account specified by the awUsername parameter.

**awTenantAPIKey**

This is the REST API key that is generated in the AirWatch Console.  You locate this key at All Settings -> Advanced -> API -> REST, and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access, which is available at Customer type Organization Groups

**awGroupID**

The groupID is the integer value ID of the Organization Group where the app will be uploaded. The API key and admin credentials need to be authenticated at this Organization Group. 

The shorcut to getting this value is to navigate to **https://\<YOUR-AW-HOST>/AirWatch/#/AirWatch/OrganizationGroup/Details**.
The ID you are redirected to appears in the URL (7 in the following example). **https://\<YOUR-AW-HOST>/AirWatch/#/AirWatch/OrganizationGroup/Details/Index/7**

## Additional Information

**Logging**

When the script runs on your machine, logs will be generated under C:\Temp\Logs\<ComputerName>-downloadLGPO.log.