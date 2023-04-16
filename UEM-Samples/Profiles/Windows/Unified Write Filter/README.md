# PRODUCTIZED #

----------

# Unified Write Filter CSP

## Overview
- **Author**: Varun Murthy
- **Email**: vmurthy@vmware.com
- **Date Created**: 7/23/2017
- **Supported Platforms**: Windows 10 Enterprise, Education ONLY
- **Tested on Windows 10**: 1607, 1703

## Purpose 
The Unified Write Filter feature is a powerful feature on Windows which is designed to protect the drives on a system by reducing the number of write cycles that the drive goes through during use.

It does this by creating a drive Overlay in memory where all changes to the system are written to memory. At the end of the session the changes can be written to memory or discarded.

Common use cases are

- To protect drives on thin clients and extend their lifetime as thin clients undergo a lot of write in their usage. 
- Discard all changes after a session on a physical device after each reboot and restore it to a known working state.
	
The sample exclusions are based on the best practices to prevent Windows Defender changes from reinstalling on each reboot.

## Required Changes/Updates
Enable the Unified Write Filter on the device using the following powershell command or go to the "Turn Windows Features On or Off" section on the Add Remove Programs > Device Lockdown menu and enable the Unified Write Filter feature under 
Then deploy the custom XML in this folder. 

Add any exclusions using the pattern seen in the final few sections of the custom XML. The path must be URL encoded and be relative to the root volume.

## Caveats
Must add any exclusions that are required for your environment in order to get the right behavior for your environment.

## Additional Resources
* [Windows 10 Configuration Service Provider Reference](http://aka.ms/CSPList)
* [Unified Write Filter CSP Reference](https://docs.microsoft.com/en-us/windows/client-management/mdm/unifiedwritefilter-csp)
* [Unified Write Filter Information](https://docs.microsoft.com/en-us/windows-hardware/customize/enterprise/unified-write-filter)