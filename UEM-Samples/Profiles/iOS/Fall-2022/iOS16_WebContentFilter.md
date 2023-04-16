# iOS 16 Web Content Filter profile #

Paste the entire XML snippet (`<dict>...</dict>`) into the [Custom Settings payload](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/2011/iOS_Platform/GUID-AWT-PROFILECUSTOMSETTS.html) in Workspace ONE UEM.

```xml
<dict>
    <key>PayloadDescription</key>
    <string>Configures a Web Content Filter</string>
    <key>PayloadDisplayName</key>
    <string>Web Content Filter</string>
    <key>PayloadIdentifier</key>
    <string>838183B8-22CC-4545-928D-5544790BA36B</string>
    <key>PayloadOrganization</key>
    <string></string>
    <key>PayloadType</key>
    <string>com.apple.webcontent-filter</string>
    <key>PayloadUUID</key>
    <string>A82D487C-32D8-4F51-81DA-F9BFCDEA27AC</string>
    <key>PayloadVersion</key>
    <integer>1</integer>

    <key>FilterType</key>
    <string>Plugin</string>
    <key>AutoFilterEnabled</key>
    <false/>
    <key>UserDefinedName</key>
    <string>TestFilterName</string>
    <key>PluginBundleID</key>
    <string>TestIdentifier</string>
    <key>ServerAddress</key>
    <string>testaddress.com</string>
    <key>Organization</key>
    <string>TestOrganization</string>
    <key>FilterBrowsers</key>
    <true/>
    <key>FilterSockets</key>
    <true/>
    <key>UserName</key>
    <string>TestUsername</string>
    <key>Password</key>
    <string>TestUsername</string>

    <key>ContentFilterUUID</key>
    <string>6ED2CCF5-75DD-4403-94AA-F8487DF861BD</string>
</dict>
```

## Key Descriptions ##

| Key           | Type          | Presence | Description   |
|---------------|---------------|----------|---------------|
|`ContentFilterUUID`|string       |optional  |A globally-unique identifier for this content filter configuration. Managed apps with the same 'ContentFilterUUID' in their app attributes have their network traffic processed by the content filter.                                                    |
