# iOS 16 Cellular profile #

Paste the entire XML snippet (`<dict>...</dict>`) into the [Custom Settings payload](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/2011/iOS_Platform/GUID-AWT-PROFILECUSTOMSETTS.html) in Workspace ONE UEM.

```xml
<dict>
    <key>PayloadDescription</key>
    <string>Provides customization of carrier Access Point Name.</string>
    <key>PayloadDisplayName</key>
    <string>Advanced Settings</string>
    <key>PayloadIdentifier</key>
    <string>f1486f3a-d7b9-42b5-a7af-5328b78c70e1</string>
    <key>PayloadOrganization</key>
    <string></string>
    <key>PayloadType</key>
    <string>com.apple.cellular</string>
    <key>PayloadUUID</key>
    <string>5855b9b4-d7ae-41f6-9581-0b748e96cb98</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>AttachAPN</key>
    <dict>
        <key>Name</key>
        <string>placeholder.apn.com</string>
        <key>AuthenticationType</key>
        <string>PAP</string>
        <key>Username</key>
        <string>PlaceHolderUser</string>
        <key>Password</key>
        <string>PlaceHolderPassword</string>
        <key>AllowedProtocolMask</key>
        <integer>1</integer>
    </dict>
    <key>APNs</key>
        <array>
            <dict>
            <key>Name</key>
            <string>placeholder.apn.com</string>
            <key>AuthenticationType</key>
            <string>PAP</string>
            <key>PlaceholderUsername</key>
            <string>TestUser</string>
            <key>Password</key>
            <string>PlaceHolderPassword</string>
            <key>ProxyServer</key>
            <string>placeholderserver.com</string>
            <key>ProxyPort</key>
            <integer>90</integer>
            <key>DefaultProtocolMask</key>
            <integer>1</integer>
            <key>AllowedProtocolMask</key>
            <integer>1</integer>
            <key>AllowedProtocolMaskInRoaming</key>
            <integer>1</integer>
            <key>AllowedProtocolMaskInDomesticRoaming</key>
            <integer>1</integer>
            <key>EnableXLAT464</key>
            <true/>
            </dict>
        </array>
</dict>
```

## Key Descriptions ##

| Key           | type      | Presence | Description   |
|---------------|-----------|----------|---------------|
| `EnableXLAT464` | boolean | optional | Enables XLAT464|
