## Shared iPad Temporary Session only and session timeouts. ##

This payload includes:
* Temporary session Only
* User auto logout


Paste the entire XML snippet (`<dict>...</dict>`) into the Custom Command modal of a device in Workspace ONE UEM.

```xml
<dict>
  <key>RequestType</key>
  <string>Settings</string>
  <key>Settings</key>
  <array>
    <dict>
      <key>Item</key>
      <string>SharedDeviceConfiguration</string>
      <key>TemporarySessionOnly</key>
      <true />
      <key>UserSessionTimeout</key>
      <integer>3600</integer> <!--This value is in seconds-->
      <key>TemporarySessionTimeout</key>
      <integer>3600</integer> <!--This value is in seconds-->
    </dict>
  </array>
</dict>
```
