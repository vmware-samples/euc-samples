# Workspace ONE Sensors

## Overview
- **Authors**:Bhavya Bandi, Varun Murthy, Josue Negron, Brooks Peppin, Aaron Black, Mike Nelson, Chris Halstead, Justin Sheets, Andreano Lanusse, Adarsh Kesari, 
Saurabh Jhunjhunwala, Robert Terakedis  
- **Email**: bbandi@vmware.com, vmurthy@vmware.com, jnegron@vmware.com, bpeppin@vmware.com, aaronb@vmware.com, miken@vmware.com, chalstead@vmware.com, jsheets@vmware.com, aguedesrocha@vmware.com, kesaria@vmware.com, sjhunjhunwal@vmware.com
- **Date Created**: 11/14/2018
- **Updated**: 2/1/2021
- **Supported Platforms**: Workspace ONE 2011+
- **Tested on**: Windows 10 Pro/Enterprise 20H2+

## Purpose
These Workspace ONE Sensor samples contain PowerShell command lines or scripts that can be used in a **Devices > Sensors** payload to report back information about the Windows 10 or macOS device back to Workspace ONE.

## Description 
There are Sensor samples, templates, and a script `import_sensor_samples.ps1` to populate your environment with all of the samples.    

## Required Changes/Updates
You will want to leverage the `template_`  samples and modify any of the data, or leverage the existing samples. You can also leverage the `import_sensor_samples.ps1` script to upload the samples to your environment. Only the templates and the Sensor Importer require changes. Samples work as is, but can also be modified for your needs. 

For Windows 10 Samples be sure to use the following format when creating new samples so that they are imported correctly:

    # Description
    # Return Type: String | Integer | Boolean | DateTime
    # Execution Context: System | User
	<YOUR POWERSHELL COMMANDS>

For macOS Samples be sure to use the following format when creating new samples so that they are imported correctly:
	    
	<YOUR SENSOR COMMANDS>
	# Description
    # Return Type: String | Integer | Boolean | DateTime
    # Execution Context: System | User


### WMI Query Template
    $wmi=(Get-WmiObject WMI_Class_Name)
    write-output $wmi.Attribute_Name

### Registry Value Template 
    $reg=Get-ItemProperty "HKLM:\Key Folder\Key Name"
    write-output $reg.ValueName

### Hash Value Template 
    $file=Get-FileHash ([Environment]::SystemDirectory + "\filename.exe") -Algorithm MD5
	Write-Output $file.Hash

### Folder Size Template 
    $TargetFolder = [Environment]::GetFolderPath("MyPictures")
	$FolderInfo = Get-ChildItem $TargetFolder -Recurse -File | Measure-Object -Property Length -Sum
	$FolderSize = ($FolderInfo.Sum/1MB)
	Write-Output  ([System.Math]::Round($FolderSize))

## Workspace ONE Sensors Importer

### Synopsis 
This Powershell script allows you to automatically import PowerShell/Shell (.sh & .zsh)/Python scripts (Sensor Samples) as Workspace ONE Sensors in the Workspace ONE UEM Console. MUST RUN AS ADMIN

### Description 
Place this PowerShell script in the same directory of all of your samples (.ps1/.sh/.zsh/.py files, note file extension is not required, sha-bang will be used to determine scripting language) or use the `-SensorsDirectory` parameter to specify your directory. This script when run will parse the sensor sample scripts, check if they already exist, then upload to Workspace ONE UEM via the REST API.

### Examples 

- **Basic**: this command shows all required fields and will scan the default directory and upload the samples to Workspace ONE via the REST API using the credentials provided. 

    	.\import_sensor_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin 'administrator' `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey 'YeJtOTx/v2EpXPIEEhFo1GfAWVCfiF6TzTMKAqhTWHc=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone' `

- **Custom Directory**: using the `-SensorsDirectory` parameter tells the script where your samples exist. The directory provided must have script files which you want uploaded as Sensors. 

    	.\import_sensor_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin 'administrator' `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey 'YeJtOTx/v2EpXPIEEhFo1GfAWVCfiF6TzTMKAqhTWHc=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone' `
		-SensorsDirectory 'C:\Users\G.P.Burdell\Downloads\Sensors'

- **Assign to Smart Group**: using the `-SmartGroupID` or `-SmartGroupName` parameter will assign ALL Sensors which were uploaded and that already exist to that chosen Smart Group. ***Existing Smart Group memberships will be overwritten!*** This command is used best in a test environment to quickly test Sensors before moving Sensors to production. Obtain the Smart Group ID via API or by hovering over the Smart Group name in the console and looking at the ID at the end of the URL. 

    	.\import_sensor_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin 'administrator' `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey 'YeJtOTx/v2EpXPIEEhFo1GfAWVCfiF6TzTMKAqhTWHc=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone' `
        -SmartGroupName 'All Devices' `

- **Assign to Smart Group and Set EVENT Triggers**: using the `-SmartGroupID` or `-SmartGroupName` parameter will assign ALL Sensors which were uploaded and that already exist to that chosen Smart Group. ***Existing Smart Group memberships will be overwritten!*** This command is used best in a test environment to quickly test Sensors before moving Sensors to production. Obtain the Smart Group ID via API or by hovering over the Smart Group name in the console and looking at the ID at the end of the URL. 

    	.\import_sensor_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin 'administrator' `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey 'YeJtOTx/v2EpXPIEEhFo1GfAWVCfiF6TzTMKAqhTWHc=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone' `
        -SmartGroupName 'All Devices' `
		-TriggerType 'EVENT' `
		-LOGIN -LOGOUT -STARTUP -USER_SWITCH

- **Delete All Sensors**: using the `-DeleteSensors` switch parameter will delete ALL Sensors which were uploaded and that already exist to that chosen Organization Group. ***All Sensors will be deleted, including the Sensors which were manually added!*** 

    	.\import_sensor_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin 'administrator' `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey 'YeJtOTx/v2EpXPIEEhFo1GfAWVCfiF6TzTMKAqhTWHc=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone' `
		-DeleteSensors

- **Update Sensors or Overwrite Existing Sensors**: using the `-UpdateSensors` switch parameter will update ALL Sensors that already exist which the version in the Sensor samples. This is best used when updates and fixes are published to the source Sensor samples.

    	.\import_sensor_samples.ps1 `
        -WorkspaceONEServer 'https://as###.awmdm.com' `
        -WorkspaceONEAdmin 'administrator' `
        -WorkspaceONEAdminPW 'P@ssw0rd' `
        -WorkspaceONEAPIKey 'YeJtOTx/v2EpXPIEEhFo1GfAWVCfiF6TzTMKAqhTWHc=' `
        -OrganizationGroupName 'Digital Workspace Tech Zone' `
		-UpdateSensors

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

**SensorsDirectory**: (OPTIONAL) The directory your sensors samples are located, default location is the current PowerShell directory of this script. 

**SmartGroupName**: (OPTIONAL) If provided, all scripts in your environment will be assigned to this Smart Group. Existing assignments will be overwritten. Navigate to **Groups & Settings > Groups > Assignment Groups**. The Smart Group Name is the friendly name displayed in the Groups column. The script will default to using Managed By = Organization Group used above. **If wanting to assign, you are required to provide SmartGroupID or SmartGroupName.**

**SmartGroupID**: (OPTIONAL) If provided, all scripts in your environment will be assigned to this Smart Group. Existing assignments will be overwritten. Navigate to **Groups & Settings > Groups > Assignment Groups**. Hover over the Smart Group, then look for the number at the end of the URL, this is your Smart Group ID. **If wanting to assign, you are required to provide SmartGroupID or SmartGroupName.**
![](https://i.imgur.com/IjvkoGC.png)

**DeleteSensors**: (OPTIONAL) If enabled, all sensors in your environment will be deleted. This action cannot be undone. Ensure you are targeting the correct Organization Group. 

**UpdateSensors** (OPTIONAL) If enabled, all sensors that match will be updated with the version in the Sensor samples.

**Platform** (OPTIONAL) Keep disabled to import all platforms. If enabled, determines what platform's sensors to import. Supported values are **Windows** or **macOS**.

**ExportSensors** (OPTIONAL) If enabled, all sensors will be downloaded locally, this is a good option for backuping up sensors before making updates. 

**TriggerType** (OPTIONAL) When bulk assigning, provide the Trigger Type: **SCHEDULE**, **EVENT**, or **SCHEDULEANDEVENT**

**LOGIN** (OPTIONAL) When using **Event** or **SCHEDULEANDEVENT** as **TriggerType** provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', or 'USER_SWITCH'

**LOGOUT** (OPTIONAL) When using **Event** or **SCHEDULEANDEVENT** as **TriggerType** provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', or 'USER_SWITCH'

**STARTUP** (OPTIONAL) When using **Event** or **SCHEDULEANDEVENT** as **TriggerType** provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', or 'USER_SWITCH'

**USER_SWITCH** (OPTIONAL) When using **Event** or **SCHEDULEANDEVENT** as **TriggerType** provide the Trigger(s): 'LOGIN', 'LOGOUT', 'STARTUP', or 'USER_SWITCH'

## Resources 
- [macOS Custom Attributes to Sensors Migration Script](https://github.com/vmware-samples/euc-samples/tree/master/macOS-Samples/Tools/CustomAttributesToSensorsMigration)
- [macOS Custom Attributes Repo](https://github.com/vmware-samples/euc-samples/tree/master/macOS-Samples/CustomAttributes)

## Change Log
- 2/1/2021 - Updated README.md. Added ability to use Organization Group ID or Name and Smart Group ID or Name. 
- 1/15/2021 - Added support for macOS. The script will now import macOS sensors automatically. Support downloading macOS sensors. Added new platform parameter to force only "Windows" or "macOS" sensors to be imported. Updated OrganizationGroupID back to OrganizationGroupName and takes in the friendly name or customer name value and NOT group ID. e.g. ACME Corp, Inc. and not acme1234. 
- 1/6/2021 - fixed issue with OrganizationGroupName; renamed to OrganizationGroupID
- 12/24/2020 - Updated import_sensor_samples.ps1 (version 3.0) file. Updated Bulk Assign to leverage new Assignment APIs. Added ability to set trigger type and event triggers. Updated "OrganizationGroupName" to "OrganizationGroupID" to reduce confusion. 
- 9/14/2020 - Removed pre-check for console version and if sensors are enabled.
- 8/10/2020 - Added samples for oma-dm sync troubleshooting
- 8/3/2020 - Fix issue with bitlocker_encryption_method.ps1 sample
- 7/24/2020 - Added os_disk_free_space sensor sample. 
- 5/28/2020 - Added ability to download/export all Sensors from console to import_sensor_samples.ps1 file (version 1.3). Added various branchcache samples.
- 5/28/2020 - updated import_sensor_samples.ps1 (version 1.2) file. Fixed bug with -DeleteSensors parameter. Added additional logging. 
- 3/26/2020 - os_product_key added
- 3/13/2020 - dcu_version and dcu_lock added
- March 2020 - many BranchCache samples bc_*
- 1/2/2020 - Fixed example, missing ` which produced an error when running the example provided in import_sensor_samples.ps1 file. 
- 8/5/2019 - Added os_browser_default which returns the default web browser set on the device. Thank you for the contribution Roar Myklebust. 
- 8/2/2019 - Updated samples, updated README.md, moved template_ samples into a folder named Templates.
- 5/9/2019 - Added branch cache samples and fixed java version sample
- 5/6/2019 - Added battery health percentage
- 5/6/2019 - Added switch parameters for overwriting/updating and deleting Sensors. 
- 5/2/2019 - Added Hash, Folder Size samples and templates
- 4/26/2019 - Force use of TLS 1.2 for REST API Calls; fixed minor issues
- 12/6/2018 - Added more details on how to use import_sensor_samples.ps1
- 12/5/2018 - Added import_sensor_samples.ps1 and updated system_type, system_status, system_date, templates, system_family
- 12/3/2018 - added system_pc_type, system_status, system_family, system_type, system_thermal_state, system_wakeup_type, system_model, system_manufacturer, system_hypervisor_present, system_dns_hostname, system_username, system_name, system_domain_role, system_domain_membership, system_domain_name
- 11/30/2018 - added os_verison, os_build_version, os_build_number, os_architecture, os_edition, system_timezone, bitlocker_encryption_method, horizon_broker_url, horizon_protocol, template_get_wmi_object, template_get_registry_value
- 11/21/2018 - updated bios_secure_boot and bios_serial_number
- 11/15/2018 - changed echo to write-output in all samples
- 11/14/2018 - Uploaded README file
