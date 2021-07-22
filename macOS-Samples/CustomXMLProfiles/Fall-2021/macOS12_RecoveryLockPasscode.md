## Recovery lock passcode ##

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom Command modal of a device in Workspace ONE UEM.

```xml
<dict>
  <key>RequestType</key>
  <string>SetRecoveryLock</string>
  <key>CurrentPassword</key>
  <string>Curr3ntP@ssw0rd!</string>
  <key>NewPassword</key>
  <string>N3wP@ssw0rd!</string>
</dict>
```
