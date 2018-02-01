# Software Distribution File Staging

## Overview

* Author: Mike Nelson
* Email: miken@vmware.com
* Date Created: 1/15/2018
* Tested On: Windows 10 1709 and AirWatch 9.2.2

## Description
Applications can be staged on machines during provisions or in remote offices. This allows for the cached app files to be distributed via Software Distribution without the device having to go to the Saas or On-Premise AirWatch Servers.

## Instructions
There are two steps to the staging process:

1. Exporting Apps from a Device.
1. Importing Apps to a device during Provisioning or for a device in a remote office.

### Exporting

1. Enroll a Windows 10 device into AirWatch.
1. Install the targeted Apps on the device.
1. Run the 'Export-CachedAirWatchApplications.ps1' script to export the apps to the Destination Folder. 

### Importing

1. On an enrolled device that doesn't have the apps installed in the targeted location.
1. Run Import-CachedAirWatchApplications.ps1 script to stage the compressed apps. To run use the following command in the powershell terminal: 
 * ```.\Import-CachedAirWatchApplications -SourcePath "Path to Apps" -All``` to Import all the apps via the command line or
 * ```.\Import-CachedAirWatchApplications -SourcePath "Path to Apps"``` to show a UI that will allow for individual apps to be selected.