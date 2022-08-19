## macOS 13 Login and Background Item Management ##

Note, this payload requires macOS 13 beta 5 or later.  This payload can be used to enforce items that show up in System Preferences > General > Login Items.

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
    <key>PayloadDescription</key>
    <string>Manage the items that run at start up</string>
    <key>PayloadDisplayName</key>
    <string>Service Management</string>
    <key>PayloadIdentifier</key>
    <string>com.apple.servicemanagement.10CB2AD2-A8AD-4C44-AA0F-EB8898E53D24</string>
    <key>PayloadUUID</key>
    <string>10CB2AD2-A8AD-4C44-AA0F-EB8898E53D24</string>
    <key>PayloadOrganization</key>
    <string>VMware</string>
    <key>PayloadType</key>
    <string>com.apple.servicemanagement</string>
    <key>Rules</key>
    <array>
        <dict>
            <key>RuleType</key>
            <string>TeamIdentifier</string>
            <key>RuleValue</key>
            <string>S2ZMFGQM93</string>
            <key>Comment</key>
            <string>Wandering Wifi LLC</string>
        </dict>
    </array>
</dict>
```

### Key Descriptions ###

| Key           | Description   |
|---------------|---------------|
| Rules | An array of dictionaries for all items that should be enabled.  This key supports multiple dictionaries, so the example XML can be expanded.  Each dictionary supports the following keys. | 
| RuleType | The type of rule specified in RuleValue. | 
| RuleValue | The specific string that defines the item, or set of items, to enable.  Exact format depends on the RuleType key. | 
| Comment | Not used by device.  Use to indicate what the Rule dictionary configures. | 

The following values are supported for the RuleType key:

* BundleIdentifier - The exact bundle identifier of an application, such as "com.vmware.hub.mac".
* BundleIdentifierPrefix - The prefix of a bundle identifier, such as "com.vmware".
* Label - The exact value of the label parameter of a launchd plist, such as "com.vmware.mac.workflowd".
* LabelPrefix - The prefix of the label parameter of a launchd plist, such as "com.vmware".
* TeamIdentifier - The team identifier of an application.