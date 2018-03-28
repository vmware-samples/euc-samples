# Update Mgmt Samples

## Overview
- **Author**: Ameya Jambavalikar
- **Email**: ajambavalikar@vmware.com
- **Date Created**: 03/26/2018
- **Supported Platforms**: Windows 10 Desktop 1703 and above 
- **Supported SKUs**: Home, Pro, Enterprise, Education
- **Tested on**: Windows 10 1709 Enterprise

## Purpose 
This folder has a sample configuration that will specify an Approved Update category to a Windows 10 Desktop device for versions 1709 and above. This allows specifying approved updates without configuring other fields like "Active Hours" that are required fields when configuring the same via the AW console.

The Sample configuration approves Definitions Updates for the Windows 10 device. Other Update classification GUIDs can be found [here](https://msdn.microsoft.com/en-us/library/ff357803(v=vs.85).aspx).

## Required Changes/Updates
Please update the GUID in the `<LocURI></LocURI>` tag with the right value for your update category. You can apply more than one category GUID in a custom XML profile. Please see the CSP link provided for additional nodes and configurations.

## Change Log

## Additional Resources
* [Windows 10 Configuration Service Provider Reference](http://aka.ms/CSPList)
* [Update CSP Reference](https://docs.microsoft.com/en-us/windows/client-management/mdm/update-csp)