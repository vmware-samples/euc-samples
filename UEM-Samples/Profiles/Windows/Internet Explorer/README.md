# Internet Explorer CSP

## Overview
- **Author**: Kelby Mahoney, Josh Burris, Josue Negron
- **Email**: jnegron@vmware.com
- **Date Created**: 12/1/2017
- **Tested on**: Windows 10 Enterprise 1709

        
## DESCRIPTION
The Internet Explorer CSP and other ADMX-backed policies were introduced starting in Windows 10 version 1703, however you should stick to the latest version in order to have support for all of the policies. Microsoft allowed ADMX-backed policies to be deployed using CSPs and have added built-in support for Internet Explorer. 

This is a sample of some of the Internet Explorer CSPs which you can deploy to your devices. To deploy this sample, navigate to **Devices & User > Profile > Add > Windows > Desktop > Device > Custom Settings**, then copy and paste the SyncML into the box and publish the profile.

These are all ADMX-backed policies and require special SyncML format to enable or disable. For details, see [Understanding ADMX-backed policies](https://docs.microsoft.com/en-us/windows/client-management/mdm/understanding-admx-backed-policies).
	
## Modifications Required
- Modify the values inside of the data tags. 
- Change the target of the policies to either device or user. Inside of <LocURI> you will want to change to either ./Device/ or ./User/ but be careful as some policies support User, Device, or Both, you can reference which are support by going to the [Internet Explorer CSP Documentation ](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-internetexplorer). 

## Resources
- [Internet Explorer CSP Documentation ](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-internetexplorer)
- [Understanding ADMX-backed policies](https://docs.microsoft.com/en-us/windows/client-management/mdm/understanding-admx-backed-policies)



