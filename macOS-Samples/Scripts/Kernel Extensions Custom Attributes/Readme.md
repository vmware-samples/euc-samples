# KEXT Custom Attributes via Products

## Overview
- **Authors**: Robert Terakedis
- **Email**: rterakedis@vmware.com
- **Date Created**: 12/4/2017
- **Supported Platforms**: AirWatch version 9.2
- **Tested on macOS Versions**: macOS High Sierra

## Purpose
This shell script (kext-ca.sh) generates an array of 3rd-party loaded Kernel Extensions and writes each kernel extension ID as a Custom Attribute in the local macOS CustomAttributes plist.   This information is posted by the agent back to the AirWatch console.   Admins can then view the list of custom attributes at Devices > Staging & Provisioning > Custom Attributes > List View.   Additionally, admins can filter for the kernel extensions ("com.") and export the list for use in populating the Kernel Extensions payload.

## Required Changes/Updates
None

## Change Log
- 12/4/2017: Created Initial File



## Additional Resources
- [Technical Note TN2459 - User-Approved Kernel Extension Loading - Apple](https://developer.apple.com/library/content/technotes/tn2459/_index.html)
- [Prepare for changes to kernel extensions in macOS High Sierra - Apple](https://support.apple.com/en-us/HT208019)

