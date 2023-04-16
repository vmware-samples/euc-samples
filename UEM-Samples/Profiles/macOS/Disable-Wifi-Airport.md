## Add the following Custom XML Payload in a macOS Device-Level profile ##

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
   <key>PayloadContent</key>
    <dict>
        <key>com.apple.MCXAirPort</key>
        <dict>
            <key>Forced</key>
            <array>
                <dict>
                    <key>mcx_preference_settings</key>
                    <dict>
                        <key>DisableAirPort</key>
                        <true/>
                    </dict>
                </dict>
            </array>
        </dict>
    </dict>
    <key>PayloadEnabled</key>
    <true/>
    <key>PayloadIdentifier</key>
    <string>MCXToProfile.64F76AB9-E0B4-423E-AB10-8A55F6E77054.alacarte.customsettings.F540555D-BD39-4B44-9177-1C4A9D529183</string>
    <key>PayloadType</key>
    <string>com.apple.ManagedClient.preferences</string>
    <key>PayloadUUID</key>
    <string>F540555D-BD39-4B44-9177-1C4A9D529183</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
</dict>
```