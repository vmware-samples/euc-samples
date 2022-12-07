# Using hubcli to inititate macOS Updates

### Overview
* Date Created: 12/7/2022
* Supported Platforms: macOS Intelligent Hub 2212

With Workspace ONE Intelligent Hub 2212 for macOS, administrators now have the ability to issue the MDM commands for [ScheduleOSUpdate](https://developer.apple.com/documentation/devicemanagement/schedule_an_os_update) and [ScheduleOSUpdateScan](https://developer.apple.com/documentation/devicemanagement/schedule_an_os_update_scan).  Administrators have the ability to specify each of the parameters that the respective commands support, such as "InstallAction", "ProductVersion" and "MaxUserDeferrals" for ScheduleOSUpdate, as outlined [here](https://developer.apple.com/documentation/devicemanagement/scheduleosupdatecommand/command/updatesitem).  Note that as these MDM commands are defined by Apple's MDM protocol, certain parameters may be dependent on, or behave differently depending on, the particular version of macOS on the target device.

Below are some example commands to perform different actions on the target device.  These commands can be deployed directly through Workspace ONE UEM, or else included as part of a larger script for more sophisticated behavior.  The hubcli will ensure that the MDM command is successfully issued, but it will likely take time for the device to fully download the specified software or perform the action, and there may or may not ultimately be user interaction required depending on the exact command specified.

### Example Commands

Display the help documentation for the hubcli mdmcommand:

`hubcli mdmcommand --help
`

Issue a command to download **or** install macOS 12.6.1, depending on if the device has already downloaded it:

`hubcli mdmcommand --osupdate --productversion 12.6.1 --installaction Default
`

Issue a command to only download macOS 13.0.1.  A subsequent command can be used to perform the install:

`hubcli mdmcommand --osupdate --productversion 13.0.1 --installaction DownloadOnly
`

Issue a command to download macOS 12.6.1 if needed, and then automatically force a restart to begin the installation:

`hubcli mdmcommand --osupdate --productversion 12.6.1 --installaction InstallForceRestart`