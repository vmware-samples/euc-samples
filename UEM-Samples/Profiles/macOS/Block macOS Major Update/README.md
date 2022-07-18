## Block macOS Major Updates

* Author Names:  Robert Terakedis & Matt Zaske
* Date:  2022-07-18
* Minimal/High-Level Description:    Custom XML Payload to block the macOS Installer using MDM and the Workspace ONE Intelligent Hub system extension. 
* Tested Version:   Workspace ONE UEM 2204 + Hub 22.05


### Utilize the OS Software Delay using MDM Keys

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
</dict>
```

### Block using the Workspace ONE Intelligent Hub System Extension

This feature can use multiple combinations of installer names, bundleIDs (obtained from the Info.plist file), and the cdhash for the macOS Installer (obtained using `/usr/bin/codesign -dvvv /Applications/Install\ macOS\ Monterey.app/Contents/Resources/startosinstall`).

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM. You will find examples in this repo for Monterrey and Ventura (beta currently). 

More information on this feature can be seen here: https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/services/macOS_Platform/GUID-AppsProcessRestrictionsformacOS.html -+
