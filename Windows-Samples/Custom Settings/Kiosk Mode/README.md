# AssignedAccess CSP

## Overview
- **Author**: Josue Negron
- **Email**: jnegron@vmware.com
- **Date Created**: 6/8/2017
- **Date Updated**: 8/6/2019, Bpeppin
- **Supported Platforms**: Windows 10 Enterprise and Education
- **Tested on Windows 10**: 1511, 1607, 1703, 1803, 1809

## Purpose 
The AssignedAccess CSP is used to enable single app kiosk mode on Windows 10 devices for Universal Windows Platform (UWP) apps. For Win32 apps you can use Shell Launcher; more information can be found in the Additional Resources section below.
## Required Changes/Updates
You must update the data under **Account** using the *username* of the local user on the device or *domain\\username* for domain users on the device. You also have to update the **AUMID** value for the UWP app you would like to lock into kiosk mode. Refer to [How to Find an App's AUMID](https://docs.microsoft.com/en-us/windows-hardware/customize/enterprise/find-the-application-user-model-id-of-an-installed-app) for more information on obtaining the AUMID value. 


## Change Log
- 6/8/2017: Created Sample AssignedAccess CSP


## Additional Resources
* [Setup Multi-App Kiosk ](https://docs.microsoft.com/en-us/windows/configuration/lock-down-windows-10-to-specific-apps)
* [Setup Single-App Kiosk ](https://docs.microsoft.com/en-us/windows/configuration/kiosk-single-app)
* [Edge Settings CSP](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-browser)
* [AssignedAccess CSP](https://docs.microsoft.com/en-us/windows/client-management/mdm/assignedaccess-csp)
* [How to Find an App's AUMID](https://docs.microsoft.com/en-us/windows-hardware/customize/enterprise/find-the-application-user-model-id-of-an-installed-app)