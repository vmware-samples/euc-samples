## macOS 13 Login and Background Item Management ##

Note, this payload requires macOS 13 beta 5 or later.  This payload can be used to enforce items that show up in System Preferences > General > Login Items.

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
	<key>Rules</key>
	<array>
		<dict>
			<key>RuleType</key>
			<string>TeamIdentifier</string>
			<key>RuleValue</key>
			<string>V4Y7PP8KCJ</string>
			<key>Comment</key>
			<string>WS1 Assist</string>
		</dict>
		<dict>
			<key>RuleType</key>
			<string>TeamIdentifier</string>
			<key>RuleValue</key>
			<string>S2ZMFGQM93</string>
			<key>Comment</key>
			<string>WS1 Intelligent Hub</string>
		</dict>
	</array>
	<key>PayloadDescription</key>
	<string>Payload for Background Service Management</string>
	<key>PayloadDisplayName</key>
	<string>Disable Login Items for user selection</string>
	<key>PayloadIdentifier</key>
	<string>4DB96276-2319-44C2-AE11-C6E761FB0304</string>
	<key>PayloadUUID</key>
	<string>A9BF8FA9-CEA3-42A2-B8C1-E1998B84CBB0</string>
	<key>PayloadType</key>
	<string>com.apple.servicemanagement</string>
	<key>PayloadOrganization</key>
	<string>My Great Company</string>
	<key>PayloadScope</key>
	<string>System</string>
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