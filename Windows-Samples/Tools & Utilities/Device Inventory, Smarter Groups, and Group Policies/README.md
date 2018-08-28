# Custom Device Inventory, Smarter Groups, & Group Policies

## Overview
- **Author**: Chase Bradley
- **Publisher**: Josue Negron
- **Email**: cbradley@vmware.com, jnegron@vmware.com
- **Date Created**: 2/5/2018
- **Tested on Windows 10**: 1703/1709 Enterprise

## Purpose 
Welcome to the first release of the Device Inventory Scripts for Windows 10 with AirWatch.  The goal of these modules is to provide an easy way for users to interact with more complex functionality on the device without having to (A) learn how to build integration with AW and (B) without having to use product provisioning to make real time changes to the devices.

In the first release, there are 3 modules that will let Administrator managed their Windows 10 desktops easier with a few additional ones in Beta that we will touch on later.

The modules included in this release are:

- **GroupPolicy Import** – A wrapper around Microsoft LGPO tool that lets you install exported LGPO files (and custom generated LGPO files) via AirWatch profiles.
- **Custom Device Inventory** – A toolkit that lets you send down custom queries via AirWatch profile to your device to add the results into Custom Attributes.
- **Smarter Groups** – A toolkit designed to allow Administrators the ability to modify the grouping mechanism of the device based on either (A) PowerShell script, (B) Application Installed, (C) Profile Installed, (D) a timer or (E) a combination of any of the above.


## Change Log
- 2/5/2018: Initially published

## Assumptions & Warnings

- We will be leveraging several components in the AirWatch console which you may not be licensed for: ensure you are licensed to leverage Software Distribution (specifically ability to deploy ZIP packages to install apps). Reach out to your Workspace ONE rep if you have questions regarding licensing. 
- These scripts are open-source scripts developed by our engineers and community, thus they are **NOT** officially supported by AirWatch support. 
- Download **[LGPO.exe](https://www.microsoft.com/en-us/download/details.aspx?id=55319)** and place into **DeviceInventory_x.x.x.zip > GroupPolicy** folder

## Getting Started 
![](https://i.imgur.com/S7Er2Kb.png)

In your download folder you should have the following files:

- An **api.config** file (needs to be scrubbed)
- A zip file of the module e.g. **DeviceInventory_x.x.x.zip**
- A folder of config templates and examples e.g. **ExampleTemplates**
- A **Win10_API_Role.xml** file
- Download **[LGPO.exe](https://www.microsoft.com/en-us/download/details.aspx?id=55319)** and place into **DeviceInventory_x.x.x.zip > GroupPolicy** folder


## 1. Configure the Service Account for the API Connection
The service account with be a local AirWatch Administrator account that the devices will use for communication.  There are only a few admin rights needed for each of the models with the primary ones being read, and only a few write permissions being enabled.

### 1.1 Create Limited AirWatch Admin Role for Service Account
![](https://i.imgur.com/YBekU9L.png)

To simplify creating this role you may simply import the **Win10_API_Role.xml** into AirWatch.  The only write commands it allows are:

- Creation of a tag
- Add/remove a tag from the current device
- Change the current device OG

You can add the role in the AirWatch console on the ***Accounts > Administrators > Roles*** page, then selecting the **Import Role** button, and then uploading the XML file included.

### 1.2 Create AirWatch Admin Service Account

You will then need to create a new Admin account with the new Administrator Role at the top-level organization group.  Record the username and password and then Base64 encode them using the format:

    		Username:Password

> **Note:** I use https://base64encode.org, but there many free accounts out there.

![](https://i.imgur.com/3Se7Md6.png)

## 2. Update the "api.config" File to Match your Info
### Blank Template Provided

    {
  	"ApiConfig":{
      "DeviceId":  "",
      "OrganizationGroupId":  7,
      "Server":  "https://asXX.awmdm.com",
      "ApiKey":  "API KEY",
      "ApiAuth":  "Basic Base64 Credentials"
   	  }
    }

### Template with Sample Data

	{
	"ApiConfig":{
		"DeviceId":"",
		"OrganizationGroupId":570,
		"Server":"https://as705.awmdm.com",
		"ApiKey":"jl2o6CdlzhiOBNJAs12laEUO6kb/RK5Lsgfqga3MI7M=",
		"ApiAuth":"Basic dXNlcm5hbWU6cGFzc3dvcmQ="
		}
	}
### Steps
1. Leave DeviceID alone
2. Update OrganizationGroupId to match your environments value. You can find this # on the Organization Group detail page inside the URL. 
	1. Navigate to ***Groups & Settings > Groups > Organization Groups > Organization Group Details*** 
	2. Obtain your **OrganizationGroupId** from the URL. 
![](https://i.imgur.com/RoeA6KX.png)
3. Update the server to your API server; https://as###.awmdm.com for SaaS environments. 
	1. Navigate to ***Groups & Settings > All Settings > System > Advanced > Site URLs*** and copy our API URL 
2. Update the APIKey field to your API key (***Groups & Settings > All Settings > System > Advanced > API > REST***)
3. Use a Base64 Encoding site to encode your username and password in the following format: 

    		Username:Password
	1. Set the APIAuth to "Basic Base64" with the Base64 encoded value you generated 
2. Copy the updated **api.config** file to the ZIP folder
	1. MAC Users
		1. Unzip the contents of the **DeviceInventory** ZIP file
		2. Replace the **api.config** file inside the ZIP file with the one you just set. 
		3. Rezip the contents making sure you aren't zipping up the folder!
	4. Windows Users 
		1. Copy the **api.config** file in the **DeviceInventory** ZIP file

## 3. Customizing the Install Manifest
### Introduction
The install manifest is setup to allow developers to add components and modules quickly, while allowing administrators some control over the install process.  In this guide we will be covering the following components:

- Changing the Install Location
- User Rights Administration

### Changing the Install Location
By default, the install path is **C:\Temp** – and then within various folders within.  While the solution is designed to work in other locations. 

> **Note: There has yet to be any testing done on changing the location so proceed at your own risk until this is properly vetted.  It should work (in theory).**

In order to install in another location you need to modify all the marked location lines (*Appendix D: setup.manifest*) to match the new location.  Only modify the **C:\Temp** portion of the path.  (You can nest the path further than two lines). 

### Modifying the Restricted User access rules
The way that the solution locks down the files is:

- Encrypting any configuration and profile files using a key that is unique to the computer and SYSTEM context
- Locking out users from the file system by using Block access
- Takes ownership of the file/registry keys
- Block Full Access to core files
- Block Write, Access, Modify and Delete access to any GPOs or other files that prevent the user from accessing

The issue with the Block Access right on the file system is that the Block Access takes precedence over any other rights (even the BUILTIN\Administrator group) which makes it dangerous to use with groups.  While you can use it with a group, the preferred method is allowing the access logic to create block rules for individual users. 

> Before tampering with these configurations – ensure that you test these configurations on test machine or VM that can be re-imaged and you use the debug mode (security level 1).

***
> ***BEFORE YOU PROCEED CONFIRM YOU WILL TEST ON A TEST MACHINE.  PROCEED AT YOUR OWN RISK.***

The Security levels:

- 0 – NONE which enforces nothing
- 1 – DEBUG -will just create logs of what actions but will not commit changes 
- 2 – ON WITH LOGGING
- 3 – ON NO LOGGING

#### AccessRules vs. AccessUser

    "AccessUsers":  ["kiosk",”Users”]

> Lets you make a list of users or groups.  Limitation is that the block rules are harsh and that they take priority over other rules.  For instance – blocking BUILTIN\Users includes the current logged in users by default even if you are Administrator.

    "AccessRules": [{  "AccessLogic": [	
    					{"Group": "Users",		 
    					 "Rule": "IN"},		 
    				 	{"User": "Administrator",
    					 "Rule": "NOTIN"}
    					]
    				}]
> (**PREFERRED**) Blocks individual users of a machine based on the criteria.  Two options include User or Group.  User can support a string or an array [“User1”,User2”]. Both create the rule based on IN or NOTIN.  This gets executed on login and is a safer way to enforce blocking.
			
#### Sample using Preferred Method
	{"CreateAccessFile":{
		"Location":"$InstallLocation",
		"SecurityLevel":0,
		"AccessRules": [{
			"AccessLogic": [
				{"Group": "Users",
				"Rule": "IN"},
				{"User": "Administrator",
				"Rule": "NOTIN"}]
			 }]
		}
	}

### Additional security considerations
The biggest issue with relying on the System context is that the BUILTIN\Administrators group can impersonate it thanks to the **Impersonate a client after authentication** option.  You have two options:

1. Remove the User from the BUILTIN\Administrators Group
![](https://i.imgur.com/S64qUzN.png)
2. Use AppLocker to create a block policy for all known impersontation applications - namely PSExec, PSExec64, and the TaskScheduler.exe 

## 4. Upload the ZIP file into AirWatch Apps & Books > Internal Apps
### Steps to Upload ZIP
1. Add App
2. Choose to upload the ZIP file. If you are unable to upload please refer to the **Assumptions and Warning** section of this document 
3. Upload the package 
4. You can choose to update the **Name** of this application
5. Under the **Files** tab, upload the **Uninstall.ps1** file and enter the following in the **Uninstall Command** field
	`C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File ".\Uninstall.ps1"`
![](https://i.imgur.com/IoVUoxt.png)
6. Move to **Deployment Options** tab:
	1. Install Context = Device
	2. Admin Privileges = Yes
	3. Install Command
	`C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File ".\setup.ps1"`
![](https://i.imgur.com/rgUSewF.png)
	4. Add a file contingency (for now) that points to **“C:\Temp\Reg\Import_CustomSettings.ps1”**.  Next release will have a REG KEY
5. Change any other options to your liking then **Save & Publish** (make your assignments ensure to test with a small group before deploying to your production)

## 5. Pushing Templates as Profiles
There are two options for pushing templates as profiles to the devices: 

1. Pushing Profiles Manually (Not Preferred) 
2. Pushing Profiles using the JavaScript Injection (Preferred) 

### Pushing Profiles Manually (Not Preferred) 
What you need:

- Your favorite text editor (mine is Notepad++)
- Your favorite Base 64 encoding website (mine is https://www.base64encode.org/ )
- Your favorite JSON validator site (mine is https://jsonlint.com/ )
- Lots of patience and luck

Follow the following instructions:

1.	Copy the template from the **custom_profile_template.xml** file into a custom settings profile in the AirWatch console (***Add Profile > Windows > Windows Desktop > Device > Custom Settings***)
2.	Build your template to match your need (see the template folder for examples)
3.	Base64 encode the template
4.	Follow the comments in the XML file to complete the profile

### Pushing Profiles using the JavaScript Injection (Preferred) 
This method uses Javascript/JQuery to add a wrapper UI to the AirWatch console which provides some level of automation when building your templates.  For starters it will automatically Base64 encode the template into the custom XML field.  Second it will validate your JSON for simple error checking.  Additionally it automates some of the button pushing for you.

In order to do so you will need a Javascript injector extension that supports Jquery.

> Tested:	https://chrome.google.com/webstore/detail/custom-javascript-for-web/poakhlngfciodnhlhhgnaaelnpjljija

Copy the contents of the **custom_profile_wrapper.js** file into the extension and add your AirWatch console domain.

You’ll know it’s working because a custom templates button will appear on the Custom Settings (***Add Profile > Windows > Windows Desktop > Device > Custom Settings***) payload of a Windows Desktop profile.  Click the **Custom Templates** button. 
![](https://i.imgur.com/yczXT6I.png)

Then once you click **Apply** the profile will be ready to push. 

![](https://i.imgur.com/WKmFwEp.png)

## Limitations to the Scripts you can Run 
The scripts inside the templates have a few limitations by design.  First they attempt limited what Cmndlts, keywords, aliases and scripts.  They do this by limiting the scripts to a set of approved PowerShell verbs.  These can be customized in the **SmarterGroupLogic.psm1** file.

> $UNSAFEKeywords = @("Function")
> $SAFEApprovedCmndlets = @("Start-Sleep","Set-Location")
> $SAFEApprovedVerbs = @("Where","Get","Find","Search","Select","Show","Compare","Read","Ping","Test","Trace","Measure","Debug","Wait","Request","ConvertTo","ConvertFrom");

The script also removes the use of any aliases that don’t match these texts.  Additionally – the script attempts to check if the Cmdlet has a -WhatIf parameter indicating that the parameter is likely a write parameter.

While these measures are somewhat crude the goal is to prevent someone from A) doing something accidentally, B) prevent tampering, and C) to create some testing to the code.

All the profiles are encrypted and locked by the SYSTEM context, and if someone gains SYSTEM context we have much bigger issues than them figuring out what inventory and grouping components are on the machine.


## Appendix A: Smarter Groups Format

    {"TagMaps":[
    {
    	 "Type": "PowerShell",
    	 "PSLogic": "(Test-Path ‘HKLM:\\Software\\AirWatch’)",
    	  "TagName ": “AirWatch RegKey”
    	},
    	{
    	 "Type":"AirWatch", 
    	 "Triggers":[  
    		{"Type":"Profile",  
    		 	"Name":"Disable Cortana",
    		 	"Status":"Installed"
    		},
    		{"Type":"Application",
    			"ApplicationName":"AirWatch*",
    			"Version":">=3.0.0", 
    			"Status":"Installed"
    	}
    	] ,
    	 "TagName":"WinStage1",
    	 "Static":1  
    	},
    	{
    	 "Type":"AirWatch", 
    	 "Triggers":[  
    		{"Type":"Timer",
    			"TimerName":"Timer0",
    			"StartTime":"Now",
    			"EndTime":"10m",
    			"Active":"After"
    		}
    	 ],
    	 "NewOrganizationGroup":"OrgGroup 1" 
    	}]
    }


> **Type**  Supported values {**PowerShell** | **AirWatch**} **PowerShell** type indicates that this will be a single PowerShell command
> 
> ***PSLogic** – PowerShell Expression that needs to return a *BOOL*.
> 
> **TagName** – Name of a tag.  Does not have to be created ahead of time 
> 
> **Static** – Whether or not the tag will remove when the values are false
> ***
> **AirWatch** type requires a collection of triggers
> 
> **Triggers (array)**:  Collection of different items that need to meet for the trigger to occur
> 
> ***Type**: Supported values {**Profile** | **Application** | **Timer** | **PSLogic**} 
> ***
> **Type: Application** – Uses API values to get these
> 
> **ApplicationName***: Name of application.  Supports * as wildcards
> 
> **Status**: default Installed – Supports Removed, Installed, and InProgress 
> 
> **Version**: Supports basic logic like **>= <= < >**, no need to put **=** if you want exact or * if you want to match any. Technically supports others 
> ***
> **Type: Profiles** – Uses API values to get these
> 
> **Name***: Name of application.  Supports * as wildcards
> 
> **Status**: default Installed – Supports Removed, Installed, and InProgress 
> 
> Technically supports others 
> ***
> **Type: Timer** 
> 
> **TimerName0***:  
> 
> **StartTime**: Supports Now, #d, #h, #m, #s
> 
> **EndTime***: Supports Now, #d, #h, #m, #s
> 
> **Active**: After or During
> ***
> **Type: PowerShell**
> 
> **PSLogic***: PowerShell Expression that needs to return a BOOL. 
> ***
> 
> **NewOrganizationGroup**: Name of the org group OR 
> 
> **NewGroupID**: GroupId of the new org group
> 
> **NewOrganizationGroupID**: ID of the new org group


## Appendix B: LGPO Format

See the [LGPO.pdf](https://www.microsoft.com/en-us/download/details.aspx?id=55319) document for more information. In terms of pushing
    
    ; ----------------------------------------------------------------------
    ; PARSING Computer POLICY
    ; Source file:  C:\WINDOWS\System32\GroupPolicy\Machine\Registry.pol
    
    Computer
    Software\Policies\Microsoft\Windows\System
    DontDisplayNetworkSelectionUI
    SZ:1
    
    ; PARSING COMPLETED.
    ; ----------------------------------------------------------------------
    


## Appendix C: Device Inventory Format

    {"Systems": [{
    	"Name": "Inventory",
    	"CmndletMappings": [{
    		"Cmdlet": "Get-CIMInstance CIM_ComputerSystem",
    		"Attributes": "TotalPhysicalMemory",
    	  }]
      }]
    }
    		
    
    {"Systems": [{
    	"Name": "Inventory",
    	"CmndletMappings": [{
    	"Cmdlet": "Get-CIMInstance CIM_ComputerSystem",
    	"Attributes": "TotalPhysicalMemory",
    	"FormattedAttributes": {
    		"ComputerHostname": "$_.Name",
    		"ComputerDomain": "If($_.PartOfDomain){ $_.Domain } Else { '' }",
    		"MemoryAmount": "'{0:N2}' ($_.TotalPhysicalMemory / '1GB')"
    		}
    	}]
    },
    		{
    			"Name": "ActiveThreat#",
    			"Cmdlet": "Get-MPThreat",
    			"Attributes": "*",
    			"MappedValues": {
    				"ThreatStatusID": {
    					"0": "Detected",
    					"1": "Detected",
    					"2": "Cleaned"
    				}
    			}
    		}
    
    	]


## Appendix D: setup.manifest
    
    {"Modules":[
    	{"Name":"SharedModule",
    	 "InstallLocation":"C:\\Temp\\Shared", 			<== Install Location
    	 "Version":"1.0.0",
    	 "Manifest":[
    		{"CopyFiles":
    			{"Destination":"$InstallLocation",
    			"From":".\\Shared\\*"
    			}
    		},
    		{"CreateAccessFile":{
    			"Location":"$InstallLocation",
    			"SecurityLevel":2,
    			"AccessRules": [{
    				"AccessLogic": [					<== Security Location
    				{"Group": "Users",					<== Security Location
    				 "Rule": "IN"},						<== Security Location
    				{"User": "Administrator",			<== Security Location
    				 "Rule": "NOTIN"}					<== Security Location
    				]									<== Security Location
    			 }]
    		   }
    		},
    		{"DeleteFiles":[
    			".\\Shared\\api.config"
    		]},
    		{"CreateRegKeys":[
    			{ "Keys":[
    				{"LogPath":"C:\\Temp\\Logs"},		<== Install Location
    				{"SharedPath":"C:\\Temp\\Shared"},	<== Install Location
    				{"TestPath":"C:\\Temp\\Shared"}		<== Install Location
    			  ]
    			}
    		]},
    		{"CreateTask":{
    			"Name":"Apply_AccessPolicies",
    			"PSFile":"$InstallLocation\\ExecuteAccessPolicies.ps1",
    			"AutoStart":0
    		}}
    	  ]
    },
    	{"Name":"ImportCustomSettings",
    	 "InstallLocation":"C:\\Temp\\Reg",				<== Install Location
    	 "Version":"1.0.1",
    	 "Manifest":[
    		{"CopyFiles":
    			{"Destination":"$InstallLocation",
    			"From":".\\Reg\\*"}
    		},
    		{"CreatePaths":{
    			"Path":"$InstallLocation",
    			"Folders":["Queue","Installed","Profiles"]
    			}
    		},
    		{"CreateTask":{
    			"Name":"Install_CustomSettings",
    			"PSFile":"$InstallLocation\\Import_CustomSettings.ps1",
    			"TaskInterval":"PT5M"
    		}},
    		{"CreateTask":{
    			"Name":"Install_SmarterGroups",
    			"PSFile":"$InstallLocation\\Import_SmarterGroups.ps1",
    			"TaskInterval":"PT5M"
    		}},
    		{"CreateTask":{
    			"Name":"Install_Profiles",
    			"PSFile":"$InstallLocation\\Install_Profiles.ps1"
    		}}
    	  ]
    },
    	{"Name":"ImportGroupPolicy",
    	 "InstallLocation":"C:\\Temp\\GroupPolicy",			<== Install Location
    	 "Version":"2.0.1",
    	 "Manifest":[
    		{"CopyFiles":
    			{"Destination":"$InstallLocation",
    			"From":".\\GroupPolicy\\*"}
    		},
    		{"CreatePaths":{
    			"Path":"$InstallLocation",
    			"Folders":["Queue","Audit"]
    			}
    		},
    		{"CreateTask":{
    			"Name":"Import_GroupPolicy",
    			"PSFile":"$InstallLocation\\Import_Group_Policy_Ex.ps1"
    		}},
    		{"AccessRule":{
    			"Name":"System",
    			"Paths":[
    				"$env:SystemRoot\\System32\\GroupPolicy", 
    			 	"$env:SystemRoot\\System32\\GroupPolicyUsers"
    			],
    			"RegKeys":[]
    		}},
    		{"AccessRule":{
    			"Name":"System",
    			"Paths":[
    				"C:\\Temp\\Logs"						<== Install Location
    			],
    			"RegKeys":[]
    		}},
    		{"DeleteFiles":[
    			".\\*.zip"
    		]},
    		{"HidePaths":{
    				"Paths":["C:\\Temp\\"]					<== Install Location
    			}
    		}
    	  ]
    }   
      ]
    }	
 

