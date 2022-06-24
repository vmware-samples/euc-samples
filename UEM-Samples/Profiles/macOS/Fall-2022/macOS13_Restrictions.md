## macOS 13 Restrictions ##

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
    <key>allowUniversalControl</key>
    <false />
    <key>allowUIConfigurationProfileInstallation</key>
    <false />
    <key>allowUSBRestrictedMode</key>
    <false />
    <key>allowRapidSecurityResponseInstallation</key>
    <false />
    <key>allowRapidSecurityResponseRemoval</key>
    <false />
    <key>PayloadDisplayName</key>
    <string>macOS Ventura Restrictions</string>
    <key>PayloadDescription</key>
    <string>Restrictions</string>
    <key>PayloadOrganization</key>
    <string></string>
    <key>PayloadType</key>
    <string>com.apple.applicationaccess</string>
    <key>PayloadUUID</key>
    <string>118C15FC-F4CF-44CD-AC06-D04E6B71FF1A</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>PayloadIdentifier</key>
    <string>34CBC4CD-290B-4587-9A9D-1D22CC6C8DCB.Restrictions</string>
</dict>
```

### Key Descriptions ###

| Key           | Description   |
|---------------|---------------|
| allowUniversalControl | If false, disables Universal Control. | 
| allowUIConfigurationProfileInstallation | If false, prohibits the user from installing configuration profiles and certificates interactively. Requires a supervised device. | 
| allowUSBRestrictedMode | If false, allows the device to always connect to USB accessories while locked. On macOS, allows new USB accessories to connect without authorization. | 
| allowRapidSecurityResponseInstallation | Allow Rapid Security Response installation by user. | 
| allowRapidSecurityResponseRemoval | Allow Rapid Security Response removal by user. | 