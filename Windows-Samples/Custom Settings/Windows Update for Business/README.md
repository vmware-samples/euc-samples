# Update Mgmt Samples

## Overview
- **Author**: Brooks Peppin
- **Email**: bpeppin@vmware.com
- **Date Created**: 8/25/2020
- **Supported Platforms**: Windows 10 Desktop 1803 and above 
- **Supported SKUs**: Home, Pro, Enterprise, Education
- **Tested on**: Windows 10 1809 Enterprise and higher

## Purpose 
These sample configuration files are to be used together. The TargetVersion should be used to keep your devices locked to a specific Feature Upgrade version. This means that you are no longer "approving" or "deferring" the feature upgrade. It simply will go to (or stay on) the value that is in the profile. For example, deploying the "TargetVersion-1809.xml" as a custom settings profile will keep an 1809 device on 1809 version for the lifecycle of that version. See the Windows 10 release information page (link at bottom) for the End of Service date for each Windows 10 Version.

## Required Changes/Updates
Please update the GUID in the `<LocURI></LocURI>` tag with the right value for your update category. You can apply more than one category GUID in a custom XML profile. Please see the CSP link provided for additional nodes and configurations.

## Change Log

## Additional Resources
* [Windows 10 Release Information] (https://docs.microsoft.com/en-us/windows/release-information/)
* [Windows 10 Configuration Service Provider Reference](http://aka.ms/CSPList)
* [Update CSP Reference](https://docs.microsoft.com/en-us/windows/client-management/mdm/update-csp)