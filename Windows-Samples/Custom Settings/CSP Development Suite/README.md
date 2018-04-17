# CSP Development Suite

## Overview
- **Publisher**: Josue Negron
- **Developed by Microsoft**
- **Email**: jnegron@vmware.com
- **Date Created**: 04/17/2018
- **Tested on:** Windows Pro/Ent 1607+ and AirWatch 8.x+

        
## DESCRIPTION
The CSP Development Suite is a tool created by Microsoft to help with creating custom Configuration Service Providers (CSPs). You can quickly create SyncML profiles using DDF (definition) files. [Download the DDF files](https://docs.microsoft.com/en-us/windows/client-management/mdm/configuration-service-provider-reference#csp-ddf-files-download) for your Windows 10 build, then import this into the CSP Dev Suite. 

1. Run **CSPDevelopmentSuite.exe**
2. Select the **SyncML Generator Tool**
3. Click **File**, **Import DDF** to import your DDF for the CSP 
4. Obtain more info on how to enter values into each node by gathering more info on the CSP at [https://aka.ms/CSPList](http://aka.ms/CSPList)
5. Copy and paste the SyncML only including the **Exec**, **Add**, or **Replace** tags. None of the Atomic or SyncML tags are required. 
6. Optionally export your SyncML for later reference. 

You can create SyncML which you can deploy to your devices. To deploy this sample, navigate to **Devices & User > Profile > Add > Windows > Desktop > Device > Custom Settings**, then copy and paste the SyncML into the box and publish the profile.


## Resources
- [CSP Documentation ](https://aka.ms/CSPList)



