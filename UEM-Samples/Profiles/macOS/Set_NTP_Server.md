## Set macOS Network Time Protocol (NTP) servers

Add the following custom XML Payload in a macOS profile.

Note: You can configure multiple timeServers by comma separating them.

```
<dict>
	<key>PayloadContent</key>
	<dict>
		<key>com.apple.MCX</key>
		<dict>
			<key>Forced</key>
			<array>
				<dict>
					<key>mcx_preference_settings</key>
						<dict>
							<key>timeServer</key>
							<string>example.company.com</string>
						</dict>
				</dict>
			</array>
		</dict>
	</dict>
	<key>PayloadDescription</key>
	<string></string>
	<key>PayloadDisplayName</key>
	<string>Time Server</string>
	<key>PayloadEnabled</key>
	<true/>
	<key>PayloadIdentifier</key>
	<string>AE48659A-A226-4A9E-92F1-7D4A4A6D713B</string>
	<key>PayloadOrganization</key>
	<string>VMware</string>
	<key>PayloadType</key>
	<string>com.apple.ManagedClient.preferences</string>
	<key>PayloadUUID</key>
	<string>AE48659A-A226-4A9E-92F1-7D4A4A6D713B</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
</dict>
```