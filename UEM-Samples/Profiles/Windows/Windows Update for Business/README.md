# Windows Update for Business Ring Sample

## Overview
- **Author**: Brooks Peppin
- **Updated By**: helmlingp@vmware.com
- **Date Created**: 8/25/2020
- **Date updated**: 8/16/2022
- **Supported Platforms**: Windows 10 Desktop 1803 and above 
- **Supported SKUs**: Home, Pro, Enterprise, Education
- **Tested on**: Windows 10 1809 Enterprise and higher

## Purpose 
These sample configuration files are to be used together, deploying one Quality Update (QU) Ring profile, one Feature Update (FU) Ring profile and one Delivery Optimization profile. Combined, these profiles control Windows 10/11 Update settings as referenced below with the following design principles
1. Auto-Approved Updates
2. Deferrals to control deployment and risk
3. Delivery Optimization to control/improve download usage
4. Rapid device compliance
5. The best user experience

## Controlling Feature Update & OS Version
TargetReleaseVersion policy in the FU Ring policy should be used to keep your devices locked to a specific Feature Upgrade version. This means that you are no longer "approving" or "deferring" the feature upgrade. It simply will go to (or stay on) the value that is in the profile. ProductVersion in the FU Ring policy should be used to keep your devices locked to a specific OS Version. For example, locked to Windows 10 or forced upgrade to Windows 11.

## Typical Settings to Review or Adjust
The following settings should be reviewed and adjusted to deliver the required outcome for your environment, as well as your risk and compliance requirements. In general, all Quality Update Profiles are similar except for deferral period in days, and likewise for Feature Update Profiles.
Only the settings that need review are noted here. The Windows 10/11 Update CSP Reference as noted below should be referenced for all settings.

### Quality Update Settings
- **Update/AllowAutoUpdate** - This automatically installs the update but prompts the user to restart when complete as per the deadline & grace period settings (required).
- **Update/AllowMUUpdateService** - Allows device to pull updates for Microsoft apps.
- **Update/BranchReadinessLevel** - Sets the branch to sem-annual channel (only change if using Insider Preview Channel for UAT/Test devices).
- **Update/AutoRestartDeadlinePeriodInDays** - Deadline in days before automatically executing a scheduled restart outside of active hours.
- **Update/ConfigureDeadlineForQualityUpdates** - Deadline to install quality updates once the device sees it. Before deadline is reached, device will attempt to install outside of active hours. Once deadline it reached it will install asap.
- **Update/DeferQualityUpdatesPeriodInDays** - How many days from Quality Update release before device sees it. This is how you build out your rings. 
- **Update/ConfigureDeadlineGracePeriod** - How may days the user has to reboot the device. User can “Pick a Time”, “Restart Tonight”  or “ Restart Now”.
- **Update/ExcludeWUDriversInQualityUpdate** - Exclude Drivers in the WU Catalog being offered for install. 
- **Update/SetDisablePauseUXAccess** - Remove the ability for a user to Pause Updates in the UI.
- **Update/UpdateNotificationLevel** - Define what Windows Update notifications users see

### Feature Update Settings
- **Update/ConfigureDeadlineForFeatureUpdates** - Deadline to install the feature update once the device sees it. Before deadline is reached, device will attempt to install outside of active hours. Once deadline it reached it will install asap.
- **Update/ConfigureDeadlineGracePeriodForFeatureUpdates** - Specify a minimum number of days until restarts occur automatically for feature updates.
- **Update/ConfigureFeatureUpdateUninstallPeriod** - How long you can uninstall/rollback a feature upgrade after it is installed. This takes up disk space to best not to set this to too long. I've set it to 14 days in the example profiles. 
- **Update/DeferFeatureUpdatesPeriodInDays** - How many days from Feature Update release before device sees it. This is how you build out your rings.
- **Update/ProductVersion** - Specifies which major Windows Desktop version (eg Windows 10) to move the device to or stay on until that major version reaches end of service.
- **Update/TargetReleaseVersion** - Specifies which minor Windows Desktop version (eg 21H1) to move the device to or stay on until that minor version reaches end of service.

### Delivery Optimization Settings
- **DeliveryOptimization/DODownloadMode** - Set to Use Peers on Same Local Network. Used in conjunction with DOGroupId will provide secure Peer to Peer sharing of updates.
- **DeliveryOptimization/DOGroupId** - A GUID that specifies which devices to peer with. Can be any GUID generated in either Powershell or another GUID generator such as [VMware Policy Builder](https://vmwarepolicybuilder.com/). It does not have to be the AzureAD Tenant ID.
- **DeliveryOptimization/DOSetHoursToLimitBackgroundDownloadBandwidth** - set the hours of the day to limit background download of updates as well as the percentage of bandwidth utilised.
- **DeliveryOptimization/DOSetHoursToLimitForegroundDownloadBandwidth** - set the hours of the day to limit foreground download of updates as well as the percentage of bandwidth utilised.

## How to Create Profile
1. At the top of UEM console, click Add > Profile. Select Windows > Windows Desktop > Device Profile. 
2. Fill out the General tab as appropriate. I recommend setting the profile to "optional" while you test. Assign a Smart Group as well.
3. On the left side of the window at the bottom click on Custom Settings and then Configure.
4. Click on the sample XML file and then click "raw". Copy and paste into the "Install Settings" section of the UEM profile. 
5. Optionally configure the "Remove Settings". 
6. Click Save and Publish
7. Go to device details > Profile tab. Find the profile and install it on the device.
8. It should show green as successfully installed. You can check on the device to see the values applied by going to HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Update

## Change Log
1. Merged SharedSettings into each Quality and Feature Update Ring profile to provide flexibility of deployment.
2. Added recommended settings for Quality Update and Feature Update profiles.
3. Added recommended settings for Delivery Optimization profile & example for second location.
4. Added Pause Quality Updates and Pause Feature Updates profiles

## Additional Resources
* [Windows 10/11 Release Information](https://docs.microsoft.com/en-us/windows/release-information/)
* [Windows 10/11 Update CSP Reference](https://docs.microsoft.com/en-us/windows/client-management/mdm/policy-csp-update)
* [Managing Device Restarts after update](https://docs.microsoft.com/en-us/windows/deployment/update/waas-restart)