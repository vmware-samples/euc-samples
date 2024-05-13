# EUC-samples is now hosted https://github.com/euc-oss/euc-samples.
# This repo is no longer maintained.

# Enable Kerberos and Add Sites to Trusted Zones for SSO

## Overview
- **Author**: Josue Negron
- **Email**: jnegron@vmware.com
- **Date Created**: 8/1/2017
- **Supported Platforms**: Windows 7/8.1/10
- **Tested on Windows 10**: 1703

## Purpose 
This sample BATCH script will enable Kerberos on a Windows device, enable sending authentication (domain credentials) to trusted sites which you have added into the trusted zones in this script. 

## Details
The device must be domain joined for these features to work. This script is for Internet Explorer, however other browsers may require some additional configurations which can be added to this sample. 

For additional information on modifying other internet options features please refer to [Internet Explorer security zones registry entries for advanced users](https://support.microsoft.com/en-us/help/182569/internet-explorer-security-zones-registry-entries-for-advanced-users).

Deploy the .bat file via AirWatch's Product Provisioning.

## Required Updates
You will have to modify the sites on lines 9 and 10 to add a list of your corporate sites. 

## Change Log
- 8/1/2017: Created Sample BATCH file


## Additional Resources
* [Internet Explorer security zones registry entries for advanced users](https://support.microsoft.com/en-us/help/182569/internet-explorer-security-zones-registry-entries-for-advanced-users)
