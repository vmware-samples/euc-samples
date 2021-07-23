## Recovery lock passcode ##

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom Command modal of a device in Workspace ONE UEM.

```xml
<dict>
  <key>RequestType</key>
  <string>SetRecoveryLock</string>
  <key>CurrentPassword</key> <!-- Only required if a password has been set already -->
  <string>Curr3ntP@ssw0rd!</string>
  <key>NewPassword</key> <!-- Set as empty string to clear the password -->
  <string>N3wP@ssw0rd!</string>
</dict>
```
