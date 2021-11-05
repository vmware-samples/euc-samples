## Block macOS Monterey Upgrades

* Author Name:  Robert Terakedis
* Date:  2021-10-28
* Minimal/High-Level Description:    Custom XML Payload to block the Monterey Installer using MDM and the Workspace ONE Intelligent Hub system extension. 
* Tested Version:   Workspace ONE UEM 2107 + Hub 21.07


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

### Block using the Workspace ONE Intelligent Hub System Extension

The following uses multiple combinations of installer names, bundleIDs (obtained from the Info.plist file), and the cdhash for the GA release of macOS Monterey (obtained using `/usr/bin/codesign -dvvv /Applications/Install\ macOS\ Monterey.app/Contents/Resources/startosinstall`).

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
                    			<string>Install macOS Monterey Beta</string>
				</array>
				<key>bundleId</key>
				<array>
					<string>com.apple.InstallAssistant.Monterey</string>
					<string>com.apple.InstallAssistant.macOSMonterey</string>
					<string>com.apple.InstallAssistant.Seed.macOS12Seed1</string>
				</array>
				<key>cdhash</key>
				<array>
					<string>315413acae0f4d1063691c9ecfd3c8d625196353</string>
				</array>
			</dict>
			<key>Actions</key>
			<array>
			<integer>1</integer>
			</array>
			<key>Message</key>
			<string>You are not permitted to install macOS Monterey.</string>
		</dict>
	</array>
	<key>PayloadDisplayName</key>
	<string>Restricted Software Policy</string>
	<key>PayloadOrganization</key>
	<string>VMware</string>
	<key>PayloadType</key>
	<string>com.vmware.hub.mac.restrictions</string>
	<key>PayloadUUID</key>
	<string>928E9628-01D8-40D9-A630-23B6E32CB3ED</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
</dict>
```

