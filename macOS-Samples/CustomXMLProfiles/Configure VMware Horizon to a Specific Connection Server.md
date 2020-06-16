## Configure VMware Horizon to a Specific Connection Server

Add the following Custom Settings Payload in a macOS profile.

Note: make sure to replace the example Test Drive servers with your actual Horizon Connection Servers

```
<dict>
	<key>PayloadUUID</key>
	<string>35E4D9F0-6C02-4B54-B60D-5E8E9D799419</string>
	<key>PayloadType</key>
	<string>com.apple.ManagedClient.preferences</string>
	<key>PayloadOrganization</key>
	<string>Workspace ONE</string>
	<key>PayloadIdentifier</key>
	<string>com.vmware.horizon.35E4D9F0-6C02-4B54-B60D-5E8E9D799419</string>
	<key>PayloadDisplayName</key>
	<string>VMware Horizon Settings</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
	<key>PayloadEnabled</key>
	<true/>
	<key>PayloadContent</key>
	<dict>
		<key>com.vmware.horizon</key>
		<dict>
			<key>Forced</key>
			<array>
				<dict>
					<key>mcx_preference_settings</key>
					<dict>
						<key>defaultBroker</key>
						<string>https://horizon.testdrive.vmware.com:443/broker/xml</string>
						<key>promptedUSBPrintingServicesInstall</key>
						<true/>
						<key>broker-history</key>
						<array>
							<string>https://horizon.testdrive.vmware.com:443/broker/xml</string>
						</array>
						<key>trustedServers</key>
						<array>
							<string>https://horizon.testdrive.vmware.com:443/broker/xml</string>
						</array>
						<key>kAutoCheckForUpdates</key>
						<false/>
						<key>kAutoDownloadForUpdates</key>
						<false/>
						<key>kAllowDataSharing</key>
						<false/>
						<key>kAllowRemovableStorage</key>
						<false/>
					</dict>
				</dict>
			</array>
		</dict>
	</dict>
	<key>PayloadDescription</key>
	<string>Created by WS1 mobileConfig Importer</string>
</dict>
```