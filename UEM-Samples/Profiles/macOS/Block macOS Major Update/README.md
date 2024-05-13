# EUC-samples is now hosted https://github.com/euc-oss/euc-samples.
# This repo is no longer maintained.

## Block macOS Major Updates

* Author Names:  Robert Terakedis & Matt Zaske
* Date:  2022-07-18
* Minimal/High-Level Description:    Custom XML Payload to block the macOS Installer using MDM and the Workspace ONE Intelligent Hub system extension. 
* Tested Version:   Workspace ONE UEM 2204 + Hub 22.05

### UPDATE

With the release of macOS Sonoma (14.x), not all Mac devices will pull down the full installer in order to conduct the update. Some devices on newer releases of Ventura will only pull down a delta update (smaller file size), and the process is handled completely within Software Update. Due to this the blockSonoma custom settings profile will not block these devices from updating using the delta update. We recommend utilizing the delay major OS update functionality seen below to ensure devices are not unexpectedly updated to macOS Sonoma. 

### Utilize the OS Software Delay using MDM Keys

**NEW - this can now be configured in the UI on UEM v2306+ (see further down for custom settings XML if not on UEM v2306+):**

![image](https://github.com/mzaske3/euc-samples/assets/63124926/0040f665-96b5-4756-91d8-8bfa90ceb87b)


The following delays Major OS updates (*enforcedSoftwareUpdateMajorOSDeferredInstallDelay*) by 45 days, and defers minor OS updates (*enforcedSoftwareUpdateMinorOSDeferredInstallDelay*) by 7 days.  Feel free to modify to your own needs (values must be between 1-90 days).

```XML
<dict>
    <key>PayloadType</key>
    <string>com.apple.applicationaccess</string>
    <key>PayloadDisplayName</key>
    <string>Software Updates Deferral Policy</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>forceDelayedMajorSoftwareUpdates</key>
    <true />
    <key>enforcedSoftwareUpdateMajorOSDeferredInstallDelay</key>
    <integer>45</integer>
    <key>forceDelayedSoftwareUpdates</key>
    <true />
    <key>enforcedSoftwareUpdateMinorOSDeferredInstallDelay</key>
    <integer>7</integer>
    <key>PayloadUUID</key>
    <string>7E8B2E01-813F-4B4D-8DE6-D37792008851</string>
    <key>PayloadIdentifier</key>
    <string>com.apple.applicationaccess.7E8B2E01-813F-4B4D-8DE6-D37792008851</string>
</dict>
```

### Block using the Workspace ONE Intelligent Hub System Extension

This feature can use multiple combinations of installer names, bundleIDs (obtained from the Info.plist file), and the cdhash for the macOS Installer (obtained using `/usr/bin/codesign -dvvv /Applications/Install\ macOS\ Monterey.app/Contents/Resources/startosinstall`).

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM. You will find examples in this repo for blocking Monterey and Ventura (beta currently). 

More information on this feature can be seen here: https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/macOS_Platform/GUID-AppsProcessRestrictionsformacOS.html
