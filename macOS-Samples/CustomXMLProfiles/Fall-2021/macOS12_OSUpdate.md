## macOS 12 OS Update ##

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom Command modal of a device in Workspace ONE UEM.

```xml
<dict>
  <key>RequestType</key>
  <string>ScheduleOSUpdate</string>
  <key>Updates</key>
  <array>
      <dict>
          <key>InstallAction</key>
          <string>InstallASAP</string>
          <key>ProductKey</key>
          <string>_MACOS_12.0</string>
          <key>ProductVersion</key>
          <string>12.0</string>
          <key>MaxUserDeferrals</key> <!-- New Key -->
          <string>5</string>
      </dict>
  </array>
</dict>
```
