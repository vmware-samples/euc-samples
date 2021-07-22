## macOS 12 Device Information ##

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom Command modal of a device in Workspace ONE UEM.

```xml
<dict>
  <key>RequestType</key>
  <string>DeviceInformation</string>
  <key>Queries</key>
     <array>
      <string>IsAppleSilicon</string>
      <string>SupportsiOSAppInstalls</string>
    </array>
</dict>
```
