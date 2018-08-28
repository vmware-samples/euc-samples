# CleanPC CSP

## Overview
- **Author**: Josue Negron
- **Email**: jnegron@vmware.com
- **Date Created**: 7/11/2017
- **Supported Platforms**: Windows 10 Enterprise and Education
- **Tested on Windows 10**: 1703

## Purpose 
The [CleanPC CSP](https://docs.microsoft.com/en-us/windows/client-management/mdm/cleanpc-csp) is used to remove usr-installed and pre-installed apps, with the ability to either retain user data or completely remove user data. This CSP was added in Windows 10 1703. 

## Details
The [CleanPC CSP ](https://docs.microsoft.com/en-us/windows/client-management/mdm/cleanpc-csp) is the ability to remotely execute a PC Refresh (via MDM) which users can do manually on their device by going to **Settings > Update & Security > Recovery > Reset this PC > Get Started**, then you are presented with **Keep my Files** or **Remove Everything**. This best explains the differences between Retaining User Data and without Retaining User Data. 

**Note:** Calling these CSPs will un-enroll your device. If you are using the AirWatch Agent this will also be removed when calling retaining user data option. When the AirWatch Agent is removed this will un-enroll your device. 


## Change Log
- 7/11/2017: Created Samples for CleanPC CSP
- 11/10/2017: Added warning about using User Retain option


## Additional Resources
* [Windows 10 Configuration Service Provider Reference](http://aka.ms/CSPList)
* [CleanPC CSP Reference](https://docs.microsoft.com/en-us/windows/client-management/mdm/cleanpc-csp)
