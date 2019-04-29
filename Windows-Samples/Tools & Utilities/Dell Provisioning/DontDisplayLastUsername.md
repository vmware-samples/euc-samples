# Don't Display Last Username and Windows Logon Screen

## Overview
- **Author**: Brooks Peppin
- **Email**: bpeppin@vmware.com
- **Date Created**: 3/21/2018
- **Supported Platforms**: Workspace ONE 1811 or newer
- **Tested on**: Windows 10 Pro/Enterprise 1803+

## Purpose
If you implement the "ZeroTouchDomainJoin" command which automatically logs out of the administrator account, the user will be presented with a Windows Logon screen that asks for the administrator password. You have to manually click on "Other user" to login with normal domain join creds. Non-technical users are generally not aware of this process. To fix this, you can add a registry key that tells Windows not to remember the account of the last user to login. This will result in a standard username and password field. Keep in mind this setting applies to all users on the device.

## Steps to Implement
1. In the Workspace ONE console, create a new provisioning package by going to Devices > Lifecycle > Staging > Windows > New.
2. On Configurations page, copy and paste the command specified below into the "Additional Synchronous Commands" section.
3. Complete the wizard and ensure the command is formatted properly. If any of the special characters don't render properly, simply manually edit the XML file to correct. 

## Command
cmd /c reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v dontdisplaylastusername /t REG_SZ /d 1 /f