## Restrict delays on major and minor software updates on macOS ##

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
    <key>PayloadDisplayName</key>
    <string>Restrict software updates and allow Erase All Content and Settings</string>
    <key>PayloadEnabled</key>
    <true/>
    <key>PayloadIdentifier</key>
    <string>com.apple.applicationaccess.allowAutoUnlock</string>
    <key>PayloadType</key>
    <string>com.apple.applicationaccess</string>
    <key>PayloadUUID</key>
    <string>8D8739D2-B3A1-41AB-8302-E72D979DXXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>forceDelayedMajorSoftwareUpdates</key> <!-- This key is required for enforcedSoftwareUpdateMajorOSDeferredInstallDelay-->
    <true />
    <key>enforcedSoftwareUpdateMajorOSDeferredInstallDelay</key>
    <integer>90</integer>
    <key>forceDelayedSoftwareUpdates</key> <!-- This key is required for enforcedSoftwareUpdateMinorOSDeferredInstallDelay-->
    <true />
    <key>enforcedSoftwareUpdateMinorOSDeferredInstallDelay</key>
    <integer>90</integer>
    <key>forceDelayedAppSoftwareUpdates</key> <!-- This key is required for enforcedSoftwareUpdateNonOSDeferredInstallDelay-->
    <true />
    <key>enforcedSoftwareUpdateNonOSDeferredInstallDelay</key>
    <integer>90</integer>
    <key>allowEraseContentAndSettings</key>
    <false />
</dict>
```
