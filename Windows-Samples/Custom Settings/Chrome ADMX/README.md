# Chrome ADMX

## Overview
- **Author**: Josue Negron
- **Email**: jnegron@vmware.com
- **Date Created**: 12/1/2017
- **Tested on**: Windows 10 Enterprise 1709

        
## Description
ADMX-backed policies were introduced starting in Windows 10 version 1703, however you should stick to the latest version in order to have support for all of the policies. Microsoft allowed ADMX-backed policies to be deployed using CSPs, this sample will show you how to deploy the Chrome ADMX template (easily be modified to support any other ADMX template). As well as push out ADMX-backed Chrome policies to the device once the ADMX template is installed. Please reference the resources below to figure out what value (format) needs to go inside of the data tag. This varies depending on the element type such as: text, List, Enum, MultiText, No Elements, etc. 

You can deploy these Chrome CSPs samples via AirWatch. To deploy navigate to **Devices & User > Profile > Add > Windows > Desktop > Device > Custom Settings**, then copy and paste the SyncML into the box and publish the profile.

These are all ADMX-backed policies and require special SyncML format to enable or disable. For details, see [Understanding ADMX-backed policies](https://docs.microsoft.com/en-us/windows/client-management/mdm/understanding-admx-backed-policies).

## Background
In addition to standard policies, the Policy CSP can now also handle ADMX-backed policies. In an ADMX-backed policy, an administrative template contains the metadata of a Window Group Policy and can be edited in the Local Group Policy Editor on a PC. Each administrative template specifies the registry keys (and their values) that are associated with a Group Policy and defines the policy settings that can be managed. Administrative templates organize Group Policies in a hierarchy in which each segment in the hierarchical path is defined as a category. Each setting in a Group Policy administrative template corresponds to a specific registry value. These Group Policy settings are defined in a standards-based, XML file format known as an ADMX file. For more information, see [Group Policy ADMX Syntax Reference Guide](https://technet.microsoft.com/en-us/library/cc753471(v=ws.10).aspx).

ADMX files can either describe operating system (OS) Group Policies that are shipped with Windows or they can describe settings of applications, which are separate from the OS and can usually be downloaded and installed on a PC. Depending on the specific category of the settings that they control (OS or application), the administrative template settings are found in the following two locations in the Local Group Policy Editor:

- OS settings: Computer Configuration/Administrative Templates
- Application settings: User Configuration/Administrative Templates

In a domain controller/Group Policy ecosystem, Group Policies are automatically added to the registry of the client computer or user profile by the Administrative Templates Client Side Extension (CSE) whenever the client computer processes a Group Policy. Conversely, in an MDM-managed client, ADMX files are leveraged to define policies independent of Group Policies. Therefore, in an MDM-managed client, a Group Policy infrastructure, including the Group Policy Service (gpsvc.exe), is not required.

An ADMX file can either be shipped with Windows (located at `%SystemRoot%\policydefinitions`) or it can be ingested to a device through the Policy CSP URI (`./Vendor/MSFT/Policy/ConfigOperations/ADMXInstall`). Inbox ADMX files are processed into MDM policies at OS-build time. ADMX files that are ingested are processed into MDM policies post-OS shipment through the Policy CSP. Because the Policy CSP does not rely upon any aspect of the Group Policy client stack, including the PC’s Group Policy Service (GPSvc), the policy handlers that are ingested to the device are able to react to policies that are set by the MDM.

Windows maps the name and category path of a Group Policy to a MDM policy area and policy name by parsing the associated ADMX file, finding the specified Group Policy, and storing the definition (metadata) in the MDM Policy CSP client store. When the MDM policy is referenced by a SyncML command and the Policy CSP URI, `.\[device|user]\vendor\msft\policy\[config|result]\<area>\<policy>`, this metadata is referenced and determines which registry keys are set or removed. For a list of ADMX-backed policies supported by MDM, see [Policy CSP - ADMX-backed policies](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-configuration-service-provider#admx-backed-policies).

Reference for [Background section](https://docs.microsoft.com/en-us/windows/client-management/mdm/understanding-admx-backed-policies#a-href-idbackgroundabackground) taken from [Microsoft](https://docs.microsoft.com/en-us/windows/client-management/mdm/understanding-admx-backed-policies#a-href-idbackgroundabackground). 
	
## Modifications Required
- Modify the values inside of the data tags. 
- Change the target of the policies to either device or user. Inside of <LocURI> you will want to change to either ./Device/ or ./User/ but be careful as some policies support User, Device, or Both, you can reference which are support by looking at the Chrome ADMX template. 

## Resources
- [Understanding ADMX-backed policies](https://docs.microsoft.com/en-us/windows/client-management/mdm/understanding-admx-backed-policies)
- [Samples for ADMX Elements](https://docs.microsoft.com/en-us/windows/client-management/mdm/understanding-admx-backed-policies#a-href-idsample-syncml-for-various-admx-elementsasample-syncml-for-various-admx-elements)
- [ADMX Policy Samples](https://docs.microsoft.com/en-us/windows/client-management/mdm/understanding-admx-backed-policies#a-href-idadmx-backed-policy-examplesaadmx-backed-policy-examples)



