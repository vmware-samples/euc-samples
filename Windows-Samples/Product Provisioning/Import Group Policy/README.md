# Import Group Policy

## Overview
- **Author**: Chase Bradley
- **Email**: cbradley@vmware.com
- **Date Created**: 7/11/2017
- **Tested on Windows 10**: 1703 Enterprise

## Purpose 
This set of scripts will guide you on how to export and import group policy configurations from devices into AirWatch to push out to managed devices using AirWatch's Product Provisioning.

## Change Log
- 7/11/2017: Initial upload of Import Group Policy


## Export Steps

**Step 1**: Unzip the Setup.ps1, Setup.cmd and Import_Group_Policy.zip file to a folder.  I typically use the C:\temp\grppolicies\ folder.

> #### IMPORTANT
If you choose a non-default path, you will need to update the Scheduled Task either through the XML or through the Task Scheduler UI.

**Step 2**: Run the setup.cmd as an Administrator.  It will (1) Unzip the zip file, (2) Create a few folders and (3) Create a task

**Step 3**: Open Local Security Policy editor on windows.  Modify to your required GPOs.  Should also be able to export GPOs from an existing domain joined machine.

**Step 4**: The export utility is in the ExportTool folder, however you should be able to run the Export_Group_Policy utility through the shortcut in the base directory.  *(Don't forget to run as an Administrator.)*
		
**Step 5**: A CSV file will be created containing all the group policies on the machine in the ExportTool folder

## Import Steps

**Step 1**: Unzip the Setup.ps1 and Import_Group_Policy.zip somewhere you can upload to a product Files/Actions.

**Step 2**: Create a new Files/Action with the two previously mentioned files.  This File/Action is to setup the utility on end user machines so name is something like Import_Group_Policy-Setup  Optionally you could use the setup.cmd file to make this step easier.  The default path is C:\temp\grppolicies\.  You can use a custom path but the .XML file in the zip file needs to be edited to reflect the new path.

> #### IMPORTANT
If you choose a non-default path, you will need to update the Scheduled Task either through the XML or through the Task Scheduler UI then Re-upload into the zip.

**Step 3**: In the manifest create a Command
			{Path}\setup.cmd
			System Context
			Administrator
			
		It will (1) Unzip the zip file, (2) Create a few folders and (3) Create a task

**Step 4**: Create a product.  This product is to setup the utility on end user machines so name is something like Import_Group_Policy-Setup.  Add the File/Action.  Assign devices.
		
		
**Step 5**: Create a new File/Action.  Using the File/Action you should upload a CSV that has this format:
> Context,Type,Path,Key,Value
> 
> Machine,String,Software\Policies\Google\Chrome\ExtensionInstallSources,**delvals.,
> Machine,String,Software\Policies\Google\Chrome\ExtensionInstallSources,1,http://*.google.com/*
	
	***NOTE: The export function creates a CSV in exactly this format***
	
**Step 6**: In your manifest either (1) Command {Path}\exec_task.cmd or (2) Command {Path}\Import_Group_Policy.ps1 One runs the task the other runs it directly
	
**Step 7**: Create a product - assign to devices.
