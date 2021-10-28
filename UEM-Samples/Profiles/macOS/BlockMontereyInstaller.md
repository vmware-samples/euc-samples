## Block macOS Monterey Upgrades

* Author Name:  Robert Terakedis
* Date:  2021-10-28
* Minimal/High Level Description:    Custom XML Payload to block the Monterey Installer using MDM and the Intelligent Hub system extension. 
* Tested Version:   Workspace ONE UEM 2107 + Hub  


### Utilize the OS Software Delay using MDM Keys

The following delays Major OS updates (*enforcedSoftwareUpdateMajorOSDeferredInstallDelay*) by 45 days, and defers minor OS updates (*enforcedSoftwareUpdateMinorOSDeferredInstallDelay*) by 7 days.  Feel free to modify to your own needs.

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

### Block 
Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```Xml
<dict>
	<key>Restrictions</key>
	<array>
		<dict>
			<key>Attributes</key>
			<dict>
				<key>name</key>
				<array>
					<string>Install macOS Monterey</string>
				</array>
				<key>path</key>
				<string>/Applications/WhatsApp.app/Contents/MacOS/WhatsApp</string>
				<key>bundleId</key>
				<array>
					<string>com.apple.InstallAssistant.Monterey</string>
					<string>com.apple.InstallAssistant.macOSMonterey</string>
                    <string>com.apple.InstallAssistant.Seed.macOS12Seed1</string>
				</array>
				<key>sha256</key>
				<string>a3a459093d5660bd37493c91e90f95445dae031cf6374a06e87a7d792498166b</string>
			</dict>
			<key>Actions</key>
			<array>
			<integer>1</integer>
			</array>
			<key>Message</key>
			<string>You are not permitted to use WhatsApp</string>
		</dict>
	</array>
	<key>PayloadDisplayName</key>
	<string>Restricted Software Policy</string>
	<key>PayloadIdentifier</key>
	<string>HubSettings.93f1655a-59fb-42dc-bc31-9571275cb12b</string>
	<key>PayloadOrganization</key>
	<string>VMware</string>
	<key>PayloadType</key>
	<string>com.vmware.hub.mac.restrictions</string>
	<key>PayloadUUID</key>
	<string>1D7F0D17-369B-4766-9CA0-D2B4537657C1</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
</dict>
```

