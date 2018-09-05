## Control TouchID settings in macOS ##

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
    <key>PayloadDisplayName</key>
    <string>TouchID Configuration</string>
    <key>PayloadEnabled</key>
    <true/>
    <key>PayloadIdentifier</key>
    <string>com.apple.touchidpolicy</string>
    <key>PayloadType</key>
    <string>com.apple.touchidpolicy</string>
    <key>PayloadUUID</key>
    <string>01F21807-381F-4037-A682-5252362D9AFE</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>allowTouchID</key>
    <false/>
    <key>allowTouchIDForUnlock</key>
    <false/>
</dict>
```