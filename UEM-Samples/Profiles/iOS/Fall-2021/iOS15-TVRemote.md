## iOS 15 TV Remote ##

This is a net new payload for allowing TV Remote usage on iPhones.

This payload includes:
* Allowed device names

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>AllowedRemotes</key>
    <array>
      <dict>
        <key>TVDeviceID</key>
        <string>11:11:11:11:11:11</string>
      </dict>
      <dict>
        <key>TVDeviceName</key>
        <string>My Apple TV</string>
      </dict>
    </array>
  <key>PayloadDescription</key>
  <string>Configures TV Remote settings</string>
  <key>PayloadDisplayName</key>
  <string>TV Remote settings</string>
  <key>PayloadIdentifier</key>
  <string>com.apple.tvremote.8ECC5754-9FD5-4F2F-AB34-A8E83D2BXXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
  <key>PayloadType</key>
  <string>com.apple.tvremote</string>
  <key>PayloadUUID</key>
  <string>8ECC5754-9FD5-4F2F-AB34-A8E83D2BC16F</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
```
