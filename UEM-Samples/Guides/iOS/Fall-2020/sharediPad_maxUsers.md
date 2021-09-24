## Shared iPad Max Users and Disk Space Quota ##

This payload includes:
* Max users on the Shared iPad
* Maximum allocated disk space for each user

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
      <key>QuotaSize</key> <!--Only one of QuotaSize(MB) or ResidentUsers can be sent. If both are sent, QuotaSize will be used.-->
      <interger>10000</interger>
      <key>ResidentUsers</key>
      <integer>10</integer>
    </dict>
  </array>
</dict>
```
