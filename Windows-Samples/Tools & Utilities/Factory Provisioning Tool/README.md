# Factory Provisioning Tool

## Overview
- **Author**: Brooks Peppin
- **Email**: bpeppin@vmware.com
- **Date Created**: 10/8/2018
- **Updated**: 11/12/2018

## Introducing Dell Factory Provisioning
**New Tool Available for customers on Workspace ONE Version 1811 or newer: ** https://labs.vmware.com/flings/vmware-workspace-one-provisioning-tool
For older Workspace ONE versions, this tool is still available. 

At VMworld 2018, [Dell announced ](https://blogs.vmware.com/euc/2018/08/dell-provisioning-workspaceone.html)a new PC configuration service, which allows organizations to ship devices preconfigured with company apps and settings directly from the factory to their users. This new service, called Dell Provisioning for VMware Workspace ONE, dramatically reduces the amount of time IT spends staging devices and minimizes end user downtime. 
This service works by enabling a new "PPKG Export" function in the Workspace ONE console. This allows you as the admin to upload any of your apps (ideally the same ones you put into the gold image). Once exported, you need build a configuration file with the VMware Workspace ONE configuration tool. Send both of these to Dell and they will apply them in the factory.


## SYNOPSIS
This utility allows you to test and validate both your PPKG and XML on a test VM before sending to the Dell factory. 

## DESCRIPTION
When run, the script will tool will prompt you to select your PPKG and your configuration file (XML). You can then choose to deploy PPKG only (i.e. just your apps exported from WS1 console) or deploy the whole process (PPKG, XML, and Sysprep). This 2nd button will also pre-stage the correct Workpace ONE content on the client in order to complete enrollment after the system Syspreps and reboots so internet connectivity is required. 

## Recommended Workflow
1.	Download Windows 10 Pro x64 from MSDN or MS volume license site
2.	Install on a fresh Virtual Machine
3.	Once the system gets to the out of box screen (OOBE), hit CTRL-SHIFT-F3 to enter "Audit Mode". 
4.	Once at the desktop, drag and drop the PPKG, XML, and this tool to the desktop. (You might need to install VMware Tools if using VMware Workstation to enable drag and drop. Restarting the machine will automatically boot it back into Audit mode.) 
5.	Run the tool and select the files you dragged to the desktop
6.	Click "Apply PPKG Only" to only install apps
7.	Click "Apply PPKG, XML, and Sysprep" to initiate the end to end process, mimicking what Dell is doing in the factory. 

## Modifications Required
This script must be run as an admin and from Windows 10 "Audit Mode". 

## Known Issues
•	If you are not connected to the internet or are behind a proxy, downloading the correct Workspace ONE content to enable enrollment might fail

## Changelog
Updated 12/17/18 to **v1.8**

- Bug fixes
- Updated UI

Updated 11/12/2018 to **v1.7**

- Bug fixes
- Adds support for shutdown or restart behavior after sysprep

Updated 11/2/2018 to **v1.6**

- Added new button for "Apply XML and Sysprep only"
- Added shutdown/restart option when sysprepping
- Improved app install status text

Updated 10/17/2018 to **v1.5**

- Improved status messages of installing apps
- Fixed Workspace ONE App download issue
- Tool will now exit if an app fails to install instead of continuing with sysprep
