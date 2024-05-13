# EUC-samples is now hosted https://github.com/euc-oss/euc-samples.
# This repo is no longer maintained.

# Workspace ONE Scripts

## Overview
- **Authors**: Josue Negron, Phil Helmling, Craig Johnston
- **Email**: jnegron@vmware.com, helmlingp@vmware.com, johnstoncrai@vmware.com
- **Date Created**: 1/18/2021
- **Updated**: 05/17/2023
- **Supported Platforms**: Workspace ONE 2011+
- **Tested on**: Windows 10 Pro/Enterprise 20H2+

## Purpose
These Workspace ONE Script samples contain command lines or scripts that can be used in a **Resources > Scripts** payload to execute commands on managed Windows 10 or macOS devices and report execution status back to Workspace ONE.

## Description 
There are Script samples, templates, and a script `import_script_samples.ps1` to populate your environment with all of the samples.    

## Required Changes/Updates
You will want to leverage the `template_` samples and modify any of the data, or leverage the existing samples. You can also leverage the `import_script_samples.ps1` script to upload the samples to your environment. Only the templates and the Script Importer require changes. Samples work as is, but can also be modified for your needs. 

For Windows 10 Samples be sure to use the following format when creating new samples so that they are imported correctly:

   `# Description`  
   `# Execution Context: System | User`  
   `# Execution Architecture: EITHER64OR32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY`  
   `# Timeout: ## greater than 0`  
   `# Variables: KEY,VALUE; KEY,VALUE`  
   `<YOUR POWERSHELL COMMANDS>`

For macOS Samples be sure to use the following format when creating new samples so that they are imported correctly:
	    
   `<YOUR SCRIPT COMMANDS>`  
   `# Description`  
   `# Execution Context: System | User`  
   `# Execution Architecture: UNKNOWN`  
   `# Timeout: ## greater than 0`  
   `# Variables: KEY,VALUE; KEY,VALUE`

## Workspace ONE Scripts Importer

### Synopsis 
This Powershell script allows you to automatically import Windows 10 and macOS scripts as Workspace ONE Scripts in the Workspace ONE UEM Console. MUST RUN AS ADMIN

### Description 
Place this PowerShell script in the same directory of all of your samples (.ps1, .sh, .zsh, .py files, note file extension is not required, sha-bang will be used to determine scripting language) or use the `-ScriptsDirectory` parameter to specify your directory. This script when run will parse the sample scripts, check if they already exist, then upload to Workspace ONE UEM via the REST API. If the `-UpdateScripts` parameter is provided, existing scripts with the same name will have all metadata and Script Code updated in the console.

***The OrganizationGroupName and SmartGroupName parameters use a search function. If multiple Organization Group or Smart Groups are returned, a choice prompt will allow selection of the correct Group.***

### Examples 

- **Basic**: this command shows all required fields and will scan the default directory and upload the samples to Workspace ONE via the REST API using the credentials provided. 

   `.\import_script_samples.ps1`  
   `-WorkspaceONEServer 'https://as###.awmdm.com'`  
   `  -WorkspaceONEAdmin 'administrator'`  
   `  -WorkspaceONEAdminPW 'P@ssw0rd'`  
   `-WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E='`  
   `-OrganizationGroupName 'Digital Workspace Tech Zone'`

- **Custom Directory**: using the`-ScriptsDirectory` parameter tells the script where your samples exist. The directory provided must have script files which you want uploaded as Scripts. 

   `  .\import_script_samples.ps1`  
   `-WorkspaceONEServer 'https://as###.awmdm.com'`  
   `-WorkspaceONEAdmin 'administrator'`  
   `-WorkspaceONEAdminPW 'P@ssw0rd'`  
   `-WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E='`  
   `-OrganizationGroupName 'Digital Workspace Tech Zone'`  
   `-ScriptsDirectory 'C:\Users\G.P.Burdell\Downloads\Scripts'`

- **Assign to Smart Group**: using the `-SmartGroupID` or `-SmartGroupName` parameter will assign all Scripts uploaded to that chosen Smart Group. This command is used best in a test environment to quickly test Scripts before moving Scripts to production. Obtain the Smart Group ID via API or by hovering over the Smart Group name in the console and looking at the ID at the end of the URL to use `-SmartGroupID`. ***The SmartGroupName parameter uses a search function. If multiple Smart Groups are returned, a choice prompt will allow selection of the correct Smart Group.***

   `.\import_script_samples.ps1`  
   `-WorkspaceONEServer 'https://as###.awmdm.com'`  
   `-WorkspaceONEAdmin 'administrator'`  
   `-WorkspaceONEAdminPW 'P@ssw0rd'`  
   `-WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E='`  
   `-OrganizationGroupName 'Digital Workspace Tech Zone'`  
   `-SmartGroupName 'All Devices'`  

- **Assign to Smart Group and Set EVENT Triggers**: using the `-SmartGroupID` or `-SmartGroupName` parameter will assign all Scripts uploaded to that chosen Smart Group. You can choose to trigger scripts on Schedule, Event, or both. When using **EVENT** or **SCHEDULE_AND_EVENT** as TriggerType provide the trigger(s): **LOGIN**, **LOGOUT**, **STARTUP**, **RUN_IMMEDIATELY**, or **NETWORK_CHANGE**.

   `.\import_script_samples.ps1`  
   `-WorkspaceONEServer 'https://as###.awmdm.com'`  
   `-WorkspaceONEAdmin 'administrator'`  
   `-WorkspaceONEAdminPW 'P@ssw0rd'`  
   `-WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E='`  
   `-OrganizationGroupName 'Digital Workspace Tech Zone'`  
   `-SmartGroupName 'All Devices'`  
   `-TriggerType 'EVENT'`  
   `-LOGIN`  
   `-LOGOUT`  
   `-NETWORK_CHANGE`

- **Assign to Smart Group and Set SCHEDULE Triggers**: using the `-SmartGroupID` or `-SmartGroupName` parameter will assign all Scripts uploaded to that chosen Smart Group. You can choose to trigger scripts on Schedule, Event, or both. When using **SCHEDULE** or **SCHEDULE_AND_EVENT** as TriggerType provide the interval: **FOUR_HOURS**, **SIX_HOURS**, **EIGHT_HOURS**, **TWELEVE_HOURS**, or **TWENTY_FOUR_HOURS**. When using **SCHEDULE** or if not specifying a TriggerType, an interval of 4 hours (FOUR_HOURS) will be used, and the Event triggers will be ignored.

   `.\import_script_samples.ps1`  
   `-WorkspaceONEServer 'https://as###.awmdm.com'`  
   `-WorkspaceONEAdmin 'administrator'`  
   `-WorkspaceONEAdminPW 'P@ssw0rd'`  
   `-WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E='`  
   `-OrganizationGroupName 'Digital Workspace Tech Zone'`  
   `-SmartGroupName 'All Devices'`  
   `-TriggerType 'SCHEDULE'`  
   `-SCHEDULE 'FOUR_HOURS'`

- **Delete All Scripts**: using the `-DeleteScripts` switch parameter will delete ALL Scripts in the target Organization Group, including the Scripts which were manually added!

   `.\import_script_samples.ps1`  
   `-WorkspaceONEServer 'https://as###.awmdm.com'`  
   `-WorkspaceONEAdmin 'administrator'`  
   `-WorkspaceONEAdminPW 'P@ssw0rd'`  
   `-WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E='`  
   `-OrganizationGroupName 'Digital Workspace Tech Zone'`  
   `-DeleteScripts`

- **Update Scripts or Overwrite Existing Scripts**: using the `-UpdateScripts` switch parameter will update the Scripts that already exist with the version being uploaded. This is best used when updates and fixes are published to the source Script samples.

   `.\import_script_samples.ps1`  
   `-WorkspaceONEServer 'https://as###.awmdm.com'`  
   `-WorkspaceONEAdmin 'administrator'`  
   `-WorkspaceONEAdminPW 'P@ssw0rd'`  
   `-WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E='`  
   `-OrganizationGroupName 'Digital Workspace Tech Zone'`  
   `-UpdateScripts`

- **Export All Scripts**: using the `-ExportScripts` switch parameter will export ALL Scripts that exist in the target Organization Group, including Scripts manually added! This is a good option for backing up Scripts before making updates, or copying from UAT to PROD for example.

   `.\import_script_samples.ps1`  
   `-WorkspaceONEServer 'https://as###.awmdm.com'`  
   `-WorkspaceONEAdmin 'administrator'`  
   `-WorkspaceONEAdminPW 'P@ssw0rd'`  
   `-WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E='`  
   `-OrganizationGroupName 'Digital Workspace Tech Zone'`   
   `-ExportScripts`

### Parameters 
**-WorkspaceONEServer**: Server URL for the Workspace ONE UEM API Server e.g. https://as###.awmdm.com without the ending /API. Navigate to **All Settings -> System -> Advanced -> API -> REST API**.

**-WorkspaceONEAdmin**: An Workspace ONE UEM admin account in the tenant that is being queried.  This admin must have the API role at a minimum.

**-WorkspaceONEAdminPW**: The password that is used by the admin specified in the admin parameter

**-WorkspaceONEAPIKey**: This is the REST API key that is generated in the Workspace ONE UEM Console.  You locate this key at **All Settings -> System -> Advanced -> API -> REST API**,
and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access. 
![](https://i.imgur.com/CjiC2Qt.png)

**-OrganizationGroupName**: (OPTIONAL) The display name of the Organization Group. You can find this at the top of the console, normally your company's name. This parameter uses a function to search the tenant for the OrganizationGroupName. If multiple Organization Groups are returned, a choice prompt will allow selection of the correct Organization Group. **Required to provide OrganizationGroupName or OrganizationGroupID.**

**-OrganizationGroupID**: (OPTIONAL) The Group ID of the Organization Group. You can find this by hovering over your Organization's Name in the console. **Required to provide OrganizationGroupName or OrganizationGroupID.**
![](https://i.imgur.com/lWjWBsF.png)

**-ScriptDirectory**: (OPTIONAL) The directory your script samples are located, default location is the current PowerShell directory of this script. 

**-SmartGroupName**: (OPTIONAL) If provided, all scripts imported will be assigned to this Smart Group. Existing assignments will NOT be overwritten, only added to. Navigate to **Groups & Settings > Groups > Assignment Groups**. The Smart Group Name is the friendly name displayed in the Groups column. The script will default to using Managed By = Organization Group used above. **If wanting to assign, you are required to provide SmartGroupID or SmartGroupName.**

**-SmartGroupID**: (OPTIONAL) If provided, all scripts in your environment will be assigned to this Smart Group. Existing assignments will NOT be overwritten, only added to. Navigate to **Groups & Settings > Groups > Assignment Groups**. Hover over the Smart Group, then look for the number at the end of the URL, this is your Smart Group ID. **If wanting to assign, you are required to provide SmartGroupID or SmartGroupName.**
![](https://i.imgur.com/IjvkoGC.png)

**-DeleteScripts**: (OPTIONAL) If enabled, all scripts in your environment will be deleted. This action cannot be undone. Ensure you are targeting the correct Organization Group. 

**-UpdateScripts** (OPTIONAL) If enabled, all scripts that match will be updated with the version in the Script samples.

**-Platform** (OPTIONAL) Keep disabled to import all platforms. If enabled, determines what platform's scripts to import. Supported values are **Windows** or **macOS**.

**-ExportScript** (OPTIONAL) If enabled, all scripts will be downloaded locally, this is a good option for backing up scripts before making updates. 

**-TriggerType** (OPTIONAL) When bulk assigning, provide the Trigger Type: **SCHEDULE**, **EVENT**, or **SCHEDULE_AND_EVENT**.

**-SCHEDULE** (OPTIONAL) When using **SCHEDULE** or **SCHEDULE_AND_EVENT** as TriggerType, provide the schedule interval: 'FOUR_HOURS', 'SIX_HOURS', 'EIGHT_HOURS', 'TWELEVE_HOURS', or 'TWENTY_FOUR_HOURS'

**-LOGIN** (OPTIONAL) When using **EVENT** or **SCHEDULE_AND_EVENT** as TriggerType.

**-LOGOUT** (OPTIONAL) When using **EVENT** or **SCHEDULE_AND_EVENT** as TriggerType.

**-STARTUP** (OPTIONAL) When using **EVENT** or **SCHEDULE_AND_EVENT** as TriggerType.

**-RUN_IMMEDIATELY** (OPTIONAL) When using **EVENT** or **SCHEDULE_AND_EVENT** as TriggerType.

**-NETWORK_CHANGE** (OPTIONAL) When using **EVENT** or **SCHEDULE_AND_EVENT** as TriggerType.

## Change Log
- 05/17/2023 - Updated README.md and cleaned up import_script_samples.ps1
- 01/04/2023 - Update import_script_samples.ps1 to only assign uploaded Scripts to specified SGs rather than all Scripts within the Console
- 2/17/2023 - added new scripts, update import_script_samples.ps1 script, add standardized header format to enable more reliable import.
- 1/22/2021 - Added logic to search for sha-bang for scripts with no file extension.
- 1/20/2021 - Updated README.md. Added ability to use OG ID or Name and Smart Group ID or Name. 
- 1/19/2021 - Updated SmartGroupID from type string to integer
- 1/18/2021 - Uploaded README file and import_script_samples.ps1
