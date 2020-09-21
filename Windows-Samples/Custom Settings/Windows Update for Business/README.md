# Windows Update for Business Ring Sample

## Overview
- **Author**: Brooks Peppin
- **Email**: bpeppin@vmware.com
- **Date Created**: 8/25/2020
- **Supported Platforms**: Windows 10 Desktop 1803 and above 
- **Supported SKUs**: Home, Pro, Enterprise, Education
- **Tested on**: Windows 10 1809 Enterprise and higher

## Purpose 
These sample configuration files are to be used together. The TargetReleaseVersion should be used to keep your devices locked to a specific Feature Upgrade version. This means that you are no longer "approving" or "deferring" the feature upgrade. It simply will go to (or stay on) the value that is in the profile. For example, deploying the "TargetVersion-1809.xml" as a custom settings profile will keep an 1809 device on 1809 version for the lifecycle of that version. See the Windows 10 release information page (link at bottom) for the End of Service date for each Windows 10 Version.

## CSP Details
These target the Policy/Update CSP and are a more streamline and simplified approach that what is currently available in the Windows Update profile in Workspace ONE UEM. I'll summarize what each of these do, but you can check out the Windows 10 Update CSP reference link below to review each in more detail. It leverages the following nodes to deliver a good user experience while still enforcing patches and reboot:

- **Update/AllowAutoUpdate** - This automatically installs the update but prompt the user to restart when complete and per the deadline settings.
- **Update/AllowMUUpdateService** - Allows device to pull updates from MS (required)
- **Update/BranchReadinessLevel** - Sets the branch to sem-annual channel
- **Update/ConfigureDeadlineForFeatureUpdates** - Deadline to install the feature update once the device sees it. Before deadline is reached, device will attempt to install outside of active hours. Once deadline it reached it will install asap.
- **Update/ConfigureDeadlineForQualityUpdates** - Deadline to install quality updates once the device sees it. Before deadline is reached, device will attempt to install outside of active hours. Once deadline it reached it will install asap.
- **Update/ConfigureDeadlineGracePeriod** - How may days the user has to reboot the device. User can “Pick a Time”, “Restart Tonight”  or “ Restart Now”
- **Update/ConfigureDeadlineNoAutoReboot** - This tells the device to NOT reboot outside of active hours until deadline is reached. This helps ensure the user doesn't experience unexpected reboots if the device is online and not in use outside of active hours. Recommend setting this to true (value of 1)
- **Update/DeferQualityUpdatesPeriodInDays** - How many days from patch release before device sees it. This is how you build out your rings. 
- **Update/DeferFeatureUpdatesPeriodInDays** - Since we are using the TargetReleaseVersion CSP, this should be set to 0. 
- **Update/ScheduleImminentRestartWarning** - Non-dismissable popup alerting restart will happen in 15 minutes.
- **Update/ScheduleRestartWarning** - Dismissable popup alerting restart will happen in 2 hours.
- **Update/ConfigureFeatureUpdateUninstallPeriod** - How long you can rollback a feature upgrade after it is installed. This takes up disk space to best not to set this to too long. I've set it to 14 days in the example profiles. 

## How to Create Profile
1. At the top of UEM console, click Add > Profile. Select Windows > Windows Desktop > Device Profile. 
2. Fill out the General tab as appropriate. I recommend setting the profile to "optional" while you test. Assign a Smart Group as well.
3. On the left side of the window at the bottom click on Custom Settings and then Configure.
4. Click on the sample XML file and then click "raw". Copy and paste into the "Install Settings" section of the UEM profile. 
5. Optionally configure the "Remove Settings". Some customers paste the data into both sections so that the device never gets the data removed.
6. Click Save and Publish
7. Go to device details > Profile tab. Find the profile and install it on the device.
8. It should show green as successfully installed. You can check on the device to see the values applied by going to HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Update


## Change Log

## Additional Resources
* [Windows 10 Release Information](https://docs.microsoft.com/en-us/windows/release-information/)
* [Windows 10 Update CSP Reference](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-update)
* [Managing Device Restarts after update](https://docs.microsoft.com/en-us/windows/deployment/update/waas-restart)