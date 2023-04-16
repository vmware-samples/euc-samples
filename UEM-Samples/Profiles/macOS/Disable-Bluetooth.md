## As of iOS 11.3 and macOS 10.13.4, Bluetooth can be disabled via Managed Settings ##

### ***NOTE:  Add the following Custom XML Payload in a macOS Device-Level profile*** ###


Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
    <key>PayloadDisplayName</key>
    <string>Disable Bluetooth via MCX Settings</string>
    <key>PayloadEnabled</key>
    <true/>
    <key>PayloadIdentifier</key>
    <string>com.apple.MCXBluetooth.0D747407-7CE2-408D-AABF-0873D79BCC4B</string>
    <key>PayloadType</key>
    <string>com.apple.MCXBluetooth</string>
    <key>PayloadUUID</key>
    <string>0D747407-7CE2-408D-AABF-0873D79BCC4B</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>DisableBluetooth</key>
    <true/>
</dict>
```
