# VMware Carbon Black Cloud Sample Collection

## Overview
- **Author**: Andreano Lanusse
- **Email**: alanusse@vmware.com
- **Date Created**: 02/26/2020


## Purpose

A sample of how Carbon Black APIs can be customized and used for Automation workflows in Workspace ONE Intelligence


## Requirements

1. The latest version of [Postman](https://www.getpostman.com) 
2. Workspace ONE Intelligence
3. A Carbon Black Cloud instance
4. A Carbon Black API Key assigned to custom level access role with permission to execute quarantine device action


## How to use this sample

This collection is a sample for use within Workspace ONE Intelligence.  Please be sure to replace the variable fields (API Key, API Secret Key and ORG Key) with the values from your Carbon Black Cloud instance.

There is only one action included in this sample:
1. Quarantine Device

*Action Type* parameter - QUARANTINE - Perform quarantine action on a single device that contain the Carbon Black Cloud Sensor installed.
*Device Id[0]* parameter - Device ID in Carbon Black where the action will be executed, use ${deviceinfo_deviceid} lookup value when performing automation.
*Options Toggle* parameter - ON to quarantine device and OFF to unquarantine device
**Note:**  The API Key must be assigned to a role with permission to execute quarantine device action.

**Permissions Required** 
*API Key* - Create an API Key with Custom Access Level role in Carbon Black Cloud. The Custom Access Level role must include the permission to execute *Device Quarantine* [Device Actions](https://developer.carbonblack.com/reference/carbon-black-cloud/platform/latest/devices-api/#device-actions) for the tenant in which the action will be performed.

**Download the postman collection (JSON file) and perform the following updates** 

Replace the *{{API Key}}* with the new API Key created in Carbon Black Cloud
Replace the *{{API Secret Key}}* with the API Secret Key associated to the API Key
Replace the *{{ORG Key}}* with the ORG Key available on the API Keys page in Carbon Black Cloud Console


**Authentication**

To configure this connector in Intelligence, select the *No Authentication* type and enter the Base URL, which is the Dashboard URL for your environment. You can obtain the Dashboard URL [here](https://community.carbonblack.com/t5/Knowledge-Base/PSC-What-URLs-are-used-to-access-the-APIs/ta-p/67346). The rest of the path will be used automatically, as defined in the collection.

For more information on Carbon Black APIs, please check the [Carbon Black API Reference](https://developer.carbonblack.com/reference/carbon-black-cloud/)

## Additional Resources
[Carbon Black API Reference](https://developer.carbonblack.com/reference/carbon-black-cloud/)
[Workspace ONE Intelligence User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-AWT-WS1INT-OVERVIEW.html)
[Custom Connector User Guide](https://docs.vmware.com/en/VMware-Workspace-ONE/services/Intelligence/GUID-54333CCC-0E6D-4871-8DEA-3AFAB8378EEC.html)
[Postman Resources](https://www.getpostman.com)
