## macOS 12 OS Update ##

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom Command modal of a device in Workspace ONE UEM.

```xml
<dict>
  <key>RequestType</key>
  <string>ScheduleOSUpdate</string>
  <key>Updates</key>
    <array>
      <dict>
        <key>MaxUserDeferrals</key>
        <string>5</string>
      </dict>
    </array>
</dict>
```
