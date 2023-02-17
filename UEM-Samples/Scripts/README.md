# Workspace ONE Scripts

## Overview
- **Authors**: Josue Negron
- **Email**: jnegron@vmware.com
- **Date Created**: 1/18/2021
- **Updated**: 1/22/2021
- **Supported Platforms**: Workspace ONE 2011+ (Tech Preview Features Dependent - use CN135/137/138)
- **Tested on**: Windows 10 Pro/Enterprise 20H2+

## Purpose
These Workspace ONE Script samples contain command lines or scripts that can be used in a **Resources > Scripts** payload to execute commands on managed Windows 10 or macOS devices and report execution status back to Workspace ONE.

## Description 
There are Script samples, templates, and a script `import_script_samples.ps1` to populate your environment with all of the samples.    

## Required Changes/Updates
You will want to leverage the `template_`  samples and modify any of the data, or leverage the existing samples. You can also leverage the `import_script_samples.ps1` script to upload the samples to your environment. Only the templates and the Script Importer require changes. Samples work as is, but can also be modified for your needs. 

For Windows 10 Samples be sure to use the following format when creating new samples so that they are imported correctly:

    # Description
	# Execution Context: System | User
	# Execution Architecture: EITHER64OR32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY
	# Timeout: ## greater than 0
	# Variables: KEY,VALUE; KEY,VALUE
	<YOUR POWERSHELL COMMANDS>

For macOS Samples be sure to use the following format when creating new samples so that they are imported correctly:
	    
	<YOUR SCRIPT COMMANDS>
	# Description
	# Execution Context: System | User
	# Execution Architecture: UNKNOWN
	# Timeout: ## greater than 0
	# Variables: KEY,VALUE; KEY,VALUE

## Workspace ONE Scripts Importer

### Synopsis 
This Powershell script allows you to automatically import Windows 10 and macOS scripts as Workspace ONE Scripts in the Workspace ONE UEM Console. MUST RUN AS ADMIN

### Description 
Place this PowerShell script in the same directory of all of your samples (.ps1, .sh, .zsh, .py files) or use the -ScriptsDirectory parameter to specify your directory. This script when run will parse the sample scripts, check if they already exist, then upload to Workspace ONE UEM via the REST API. You can leverage the optional switch parameters to update scripts or delete all scripts.

### Examples 

- **Basic**: this command shows all required fields and will scan the default directory and upload the samples to Workspace ONE via the REST API using the credentials provided. 

    	.\import_script_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin 'administrator' `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone'

- **Custom Directory**: using the `-ScriptsDirectory` parameter tells the script where your samples exist. The directory provided must have script files which you want uploaded as Scripts. 

    	.\import_script_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin 'administrator' `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone' `
		-ScriptsDirectory 'C:\Users\G.P.Burdell\Downloads\Scripts'

- **Assign to Smart Group**: using the `-SmartGroupID` or `-SmartGroupName` parameter will assign ALL Scripts which were uploaded and that already exist to that chosen Smart Group. ***Existing Smart Group memberships will be overwritten!*** This command is used best in a test environment to quickly test Scripts before moving Scripts to production. Obtain the Smart Group ID via API or by hovering over the Smart Group name in the console and looking at the ID at the end of the URL. 

    	.\import_script_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin 'administrator' `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone' `
        -SmartGroupID 14

- **Assign to Smart Group and Set EVENT Triggers**: using the `-SmartGroupID` or `-SmartGroupName` parameter will assign ALL Scripts which were uploaded and that already exist to that chosen Smart Group. ***Existing Smart Group memberships will be overwritten!*** You can choose to trigger scripts on Schedule, Event, or both. When using **EVENT** or **SCHEDULE_AND_EVENT** as TriggerType provide the Trigger(s): **LOGIN**, **LOGOUT**, **STARTUP**, **RUN_IMMEDIATELY**, or **NETWORK_CHANGE**.

    	.\import_script_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin 'administrator' `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone' `
        -SmartGroupID 'All Devices' `
        -TriggerType 'EVENT' `
        -LOGIN `
		-LOGOUT `
		-NETWORK_CHANGE

- **Assign to Smart Group and Set SCHEDULE Triggers**: using the `-SmartGroupID` or `-SmartGroupName` parameter will assign ALL Scripts which were uploaded and that already exist to that chosen Smart Group. ***Existing Smart Group memberships will be overwritten!*** You can choose to trigger scripts on Schedule, Event, or both. When using **SCHEDULE** or **SCHEDULE_AND_EVENT** as TriggerType provide the interval: **FOUR_HOURS**, **SIX_HOURS**, **EIGHT_HOURS**, **TWELEVE_HOURS**, or **TWENTY_FOUR_HOURS**.

    	.\import_script_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin 'administrator' `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone' `
        -SmartGroupName 'All Devices' `
        -TriggerType 'SCHEDULE' `
        -SCHEDULE 'FOUR_HOURS'

- **Delete All Scripts**: using the `-DeleteScripts` switch parameter will delete ALL Scripts which were uploaded and that already exist to that chosen Organization Group. ***All Scripts will be deleted, including the Scripts which were manually added!*** 

    	.\import_script_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin 'administrator' `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone' `
		-DeleteScripts

- **Update Scripts or Overwrite Existing Scripts**: using the `-UpdateScripts` switch parameter will update ALL Scripts that already exist which the version in the Script samples. This is best used when updates and fixes are published to the source Script samples.

    	.\import_script_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin 'administrator' `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey '7t5NQg8bGUQdRTGtmDBXknho9Bu9W+7hnvYGzyCAP+E=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone' `
		-UpdateScripts

### Parameters 
**WorkspaceONEServer**: Server URL for the Workspace ONE UEM API Server e.g. https://as###.awmdm.com without the ending /API. Navigate to **All Settings -> System -> Advanced -> API -> REST API**.

**WorkspaceONEAdmin**: An Workspace ONE UEM admin account in the tenant that is being queried.  This admin must have the API role at a minimum.

**WorkspaceONEAdminPW**: The password that is used by the admin specified in the admin parameter

**WorkspaceONEAPIKey**: This is the REST API key that is generated in the Workspace ONE UEM Console.  You locate this key at **All Settings -> System -> Advanced -> API -> REST API**,
and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access. 
![](https://i.imgur.com/CjiC2Qt.png)

**OrganizationGroupName**: The display name of the Organization Group. You can find this at the top of the console, normally your company's name. **Required to provide OrganizationGroupName or OrganizationGroupID.**

**OrganizationGroupID**: The Group ID of the Organization Group. You can find this by hovering over your Organization's Name in the console. **Required to provide OrganizationGroupName or OrganizationGroupID.**
![](https://i.imgur.com/lWjWBsF.png)

**ScriptDirectory**: (OPTIONAL) The directory your script samples are located, default location is the current PowerShell directory of this script. 

**SmartGroupName**: (OPTIONAL) If provided, all scripts in your environment will be assigned to this Smart Group. Existing assignments will be overwritten. Navigate to **Groups & Settings > Groups > Assignment Groups**. The Smart Group Name is the friendly name displayed in the Groups column. The script will default to using Managed By = Organization Group used above. **If wanting to assigned, you are required to provide SmartGroupID or SmartGroupName.**

**SmartGroupID**: (OPTIONAL) If provided, all scripts in your environment will be assigned to this Smart Group. Existing assignments will be overwritten. Navigate to **Groups & Settings > Groups > Assignment Groups**. Hover over the Smart Group, then look for the number at the end of the URL, this is your Smart Group ID. **If wanting to assigned, you are required to provide SmartGroupID or SmartGroupName.**
![](https://i.imgur.com/IjvkoGC.png)

**DeleteScripts**: (OPTIONAL) If enabled, all scripts in your environment will be deleted. This action cannot be undone. Ensure you are targeting the correct Organization Group. 

**UpdateScripts** (OPTIONAL) If enabled, all scripts that match will be updated with the version in the Script samples.

**Platform** (OPTIONAL) Keep disabled to import all platforms. If enabled, determines what platform's scripts to import. Supported values are **Windows** or **macOS**.

**ExportScript** (OPTIONAL) If enabled, all scripts will be downloaded locally, this is a good option for backuping up scripts before making updates. 

**TriggerType** (OPTIONAL) When bulk assigning, provide the Trigger Type: **SCHEDULE**, **EVENT**, or **SCHEDULE_AND_EVENT**

**SCHEDULE** (OPTIONAL) When using **SCHEDULE** or **SCHEDULE_AND_EVENT** as TriggerType provide the schedule interval: 'FOUR_HOURS', 'SIX_HOURS', 'EIGHT_HOURS', 'TWELEVE_HOURS', or 'TWENTY_FOUR_HOURS'

**LOGIN** (OPTIONAL) When using **EVENT** or **SCHEDULE_AND_EVENT** as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'

**LOGOUT** (OPTIONAL) When using **EVENT** or **SCHEDULE_AND_EVENT** as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'

**STARTUP** (OPTIONAL) When using **EVENT** or **SCHEDULE_AND_EVENT** as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'

**RUN_IMMEDIATELY** (OPTIONAL) When using **EVENT** or **SCHEDULE_AND_EVENT** as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'

**NETWORK_CHANGE** (OPTIONAL) When using **EVENT** or **SCHEDULE_AND_EVENT** as TriggerType provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', 'RUN_IMMEDIATELY', or 'NETWORK_CHANGE'

## Change Log
- 1/22/2021 - Added logic to search for sha-bang for scripts with no file extension.
- 1/20/2021 - Updated README.md. Added ability to use OG ID or Name and Smart Group ID or Name. 
- 1/19/2021 - Updated SmartGroupID from type string to integer
- 1/18/2021 - Uploaded README file and import_script_samples.ps1
