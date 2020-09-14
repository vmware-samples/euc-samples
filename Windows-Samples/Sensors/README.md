# Workspace ONE Sensors

## Overview
- **Authors**:Bhavya Bandi, Varun Murthy, Josue Negron, Brooks Peppin, Aaron Black, Mike Nelson, Chris Halstead, Justin Sheets, Andreano Lanusse, Adarsh Kesari
- **Email**: bbandi@vmware.com, vmurthy@vmware.com, jnegron@vmware.com, bpeppin@vmware.com, aaronb@vmware.com, miken@vmware.com, chalstead@vmware.com, jsheets@vmware.com, aguedesrocha@vmware.com, kesaria@vmware.com
- **Date Created**: 11/14/2018
- **Updated**: 9/14/2020
- **Supported Platforms**: Workspace ONE 1811+
- **Tested on**: Windows 10 Pro/Enterprise 1803+

## Purpose
These Workspace ONE Sensor samples contain PowerShell command lines or scripts that can be used in a **Provisioning > Custom Attributes > Sensors** payload to report back information about the Windows 10 device back to Workspace ONE.

## Description 
There are Sensor samples, templates, and a script `import_sensor_samples.ps1` to populate your environment with all of the samples.    

## Required Changes/Updates
You will want to leverage the `template_`  samples and modify any of the data, or leverage the existing samples. You can also leverage the `import_sensor_samples.ps1` script to upload the samples to your environment. Only the templates and the Sensor Importer require changes. Samples work as is, but can also be modified for your needs. 

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
This Powershell script allows you to automatically import PowerShell scripts (Sensor Samples) as Workspace ONE Sensors in the Workspace ONE UEM Console. MUST RUN AS ADMIN

### Description 
Place this PowerShell script in the same directory of all of your samples (.ps1 files) or use the `-SensorsDirectory` parameter to specify your directory. This script when run will parse the PowerShell sample scripts, check if they already exist, then upload to Workspace ONE UEM via the REST API.

### Examples 

- **Basic**: this command shows all required fields and will scan the default directory and upload the samples to Workspace ONE via the REST API using the credentials provided. 

    	.\import_sensor_samples.ps1 `
        -WorkspaceONEServer "https://as###.awmdm.com" `
        -WorkspaceONEAdmin "administrator" `
        -WorkspaceONEAdminPW "P@ssw0rd" `
        -WorkspaceONEAPIKey "YeJtOTx/v2EpXPIEEhFo1GfAWVCfiF6TzTMKAqhTWHc=" `
        -OrganizationGroupName "techzone"

- **Custom Directory**: using the `-SensorsDirectory` parameter tells the script where your samples exist. The directory provided must have .ps1 files which you want uploaded as Sensors. 

    	.\import_sensor_samples.ps1 `
        -WorkspaceONEServer "https://as###.awmdm.com" `
        -WorkspaceONEAdmin "administrator" `
        -WorkspaceONEAdminPW "P@ssw0rd" `
        -WorkspaceONEAPIKey "YeJtOTx/v2EpXPIEEhFo1GfAWVCfiF6TzTMKAqhTWHc=" `
        -OrganizationGroupName "techzone" `
		-SensorsDirectory "C:\Users\G.P.Burdell\Downloads\Sensors"

- **Assign to Smart Group**: using the `-SmartGroupID` parameter will assign ALL Sensors which were uploaded and that already exist to that chosen Smart Group. ***Existing Smart Group memberships will be overwritten!*** This command is used best in a test environment to quickly test Sensors before moving Sensors to production. Obtain the Smart Group ID via API or by hovering over the Smart Group name in the console and looking at the ID at the end of the URL. 

    	.\import_sensor_samples.ps1 `
        -WorkspaceONEServer "https://as###.awmdm.com" `
        -WorkspaceONEAdmin "administrator" `
        -WorkspaceONEAdminPW "P@ssw0rd" `
        -WorkspaceONEAPIKey "YeJtOTx/v2EpXPIEEhFo1GfAWVCfiF6TzTMKAqhTWHc=" `
        -OrganizationGroupName "techzone" `
		-SmartGroupID "14"

- **Delete All Sensors**: using the `-DeleteSensors` switch parameter will delete ALL Sensors which were uploaded and that already exist to that chosen Organization Group. ***All Sensors will be deleted, including the Sensors which were manually added!*** 

    	.\import_sensor_samples.ps1 `
        -WorkspaceONEServer "https://as###.awmdm.com" `
        -WorkspaceONEAdmin "administrator" `
        -WorkspaceONEAdminPW "P@ssw0rd" `
        -WorkspaceONEAPIKey "YeJtOTx/v2EpXPIEEhFo1GfAWVCfiF6TzTMKAqhTWHc=" `
        -OrganizationGroupName "techzone" `
		-DeleteSensors

- **Update Sensors or Overwrite Existing Sensors**: using the `-UpdateSensors` switch parameter will update ALL Sensors that already exist which the version in the PowerShell samples. This is best used when updates and fixes are published to the source PowerShell samples.

    	.\import_sensor_samples.ps1 `
        -WorkspaceONEServer "https://as###.awmdm.com" `
        -WorkspaceONEAdmin "administrator" `
        -WorkspaceONEAdminPW "P@ssw0rd" `
        -WorkspaceONEAPIKey "YeJtOTx/v2EpXPIEEhFo1GfAWVCfiF6TzTMKAqhTWHc=" `
        -OrganizationGroupName "techzone" `
		-UpdateSensors

### Parameters 
**WorkspaceONEServer**: Server URL for the Workspace ONE UEM API Server e.g. https://as###.awmdm.com without the ending /API. Navigate to **All Settings -> System -> Advanced -> API -> REST API**.

**WorkspaceONEAdmin**: An Workspace ONE UEM admin account in the tenant that is being queried.  This admin must have the API role at a minimum.

**WorkspaceONEAdminPW**: The password that is used by the admin specified in the admin parameter

**WorkspaceONEAPIKey**: This is the REST API key that is generated in the Workspace ONE UEM Console.  You locate this key at **All Settings -> System -> Advanced -> API -> REST API**,
and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access. 
![](https://i.imgur.com/CjiC2Qt.png)

**OrganizationGroupName**: The Group ID of the Organization Group. You can find this by hovering over your Organization's Name in the console.
![](https://i.imgur.com/lWjWBsF.png)

**SensorsDirectory**: (OPTIONAL) The directory your .ps1 sensors samples are located, default location is the current PowerShell directory of this script. 

**SmartGroupID**: (OPTIONAL) If provided, all sensors in your environment will be assigned to this Smart Group. Existing assignments will be overwritten. Navigate to **Groups & Settings > Groups > Assignment Groups**. Hover over the Smart Group, then look for the number at the end of the URL, this is your Smart Group ID. 
![](https://i.imgur.com/IjvkoGC.png)

**DeleteSensors**: (OPTIONAL) If enabled, all sensors in your environment will be deleted. This action cannot be undone. Ensure you are targeting the correct Organization Group. 

**UpdateSensors** (OPTIONAL) If enabled, all sensors that match will be updated with the version in the PowerShell samples.


## Change Log
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

## Additional Resources
Coming Soon on [techzone.vmware.com](http://techzone.vmware.com)!
