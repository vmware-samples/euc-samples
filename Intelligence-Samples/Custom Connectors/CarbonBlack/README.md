
# VMware Carbon Black Cloud Custom Connector Sample Collection

## Overview
- **Author**: Andreano Lanusse
- **Email**: alanusse@vmware.com
- **Date Created**: 02/26/2020     - **Last Update**: 07/30/2020


## Purpose

A sample of how Carbon Black APIs can be customized and used for Automation workflows in Workspace ONE Intelligence

## Requirements

1. The latest version of [Postman](https://www.getpostman.com) 
2. Workspace ONE Intelligence
3. A VMware Carbon Black Cloud instance
4. A Carbon Black Cloud API Key assigned to custom level access role with permission to execute quarantine device action


## How to use this sample

This collection is a sample for use within Workspace ONE Intelligence.  Please be sure to replace the variable fields (API Key, API Secret Key and ORG Key) with the values from your Carbon Black Cloud instance.

This sample contain two actions:

1 - Quarantine Device action, with the following parameters:

   - **Action Type** parameter - QUARANTINE - Perform quarantine action on a single device that contain the Carbon Black Cloud Sensor installed.

   - **Device Id[0]** parameter - Carbon Black Device ID where the action will be executed, use ${deviceinfo_deviceid} lookup value when performing automation.

   - **Options Toggle** parameter - ON to quarantine device and OFF to unquarantine device.

**API Key permission required:**  The API Key must be assigned to a custom role with permission to execute quarantine device action.

2 - Change Device Policy action, with the following parameters:

   - **Action Type** parameter - UPDATE_POLICY - Change the device policy on a single device with Carbon Black Sensor to a new one defined on the Policy ID.

   - **Device Id[0]** parameter - Carbon Black Device ID where the action will be executed, use ${deviceinfo_deviceid} lookup value when performing automation.
   
   - **Policy ID** parameter - New Policy ID to apply to the device.

**API Key permission required:**  The API Key must be assigned to a custom role with permission to update device polivy.

*Custom Access Level* - More information on Custom Access Level role and permissions to execute [Device Quarantine and Update Poicy Actions](https://developer.carbonblack.com/reference/carbon-black-cloud/platform/latest/devices-api/#device-actions).

**Download the postman collection (JSON file) and perform the following updates**  

- Replace the *{{APIKey}}* with the new API Key created in Carbon Black Cloud  (API Key sample: AAFFGFFIN)
- Replace the *{{APISecretKey}}* with the API Secret Key associated to the API Key  (API Secret Key sample: ZI335DR13D32EEDEZ8Z7IZD1)
- Replace the *{{OrgKey}}* with the ORG Key available on the API Keys page in Carbon Black Cloud Console  (ORG Key sample: D12DHM4C)  

Based on the sample values, the variable values on the the JSON file will look like this:  
*{{APISecretKey}}/{{APIKey}}* -> ZI335DR13D32EEDEZ8Z7IZD1/AAFFGFFIN  
*{{OrgKey}}* -> D12DHM4C  

**Configuring this Connector in Intelligence**

Steps:

1. Navigate to Settings > Integrations > Automation Connections > Add Custom Connection and add your connector detail.
2. Select the *No Authentication* type and enter the Base URL, which is the Dashboard URL for your environment. The rest of the path will be used automatically, as defined in the collection.

**Note:**  You can obtain the Dashboard URL [here](https://community.carbonblack.com/t5/Knowledge-Base/PSC-What-URLs-are-used-to-access-the-APIs/ta-p/67346). 


For more information on Carbon Black APIs, please check the [Carbon Black API Reference](https://developer.carbonblack.com/reference/carbon-black-cloud/)

## Additional Resources
[Carbon Black API Reference](https://developer.carbonblack.com/reference/carbon-black-cloud/)
[Workspace ONE Intelligence User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-AWT-WS1INT-OVERVIEW.html)
[Custom Connector User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-54333CCC-0E6D-4871-8DEA-3AFAB8378EEC.html)
[Postman Resources](https://www.getpostman.com)
