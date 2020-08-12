## iOS 14 Notifications ##

This payload includes:
* Notification preview type

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>NotificationSettings</key>
  <array>
    <dict>
      <key>BundleIdentifier</key>
      <string>com.air-watch.agent</string>
      <key>NotificationsEnabled</key>
      <true />
      <key>PreviewType</key> <!--New feature!-->
      <integer>1</integer>
    </dict>
  </array>
  <key>PayloadDisplayName</key>
  <string>Notifications</string>
  <key>PayloadDescription</key>
  <string>Notifications</string>
  <key>PayloadIdentifier</key>
  <string>195c2047-813f-423e-b8c6-56a47a721b6e.Notifications</string>
  <key>PayloadOrganization</key>
  <string></string>
  <key>PayloadType</key>
  <string>com.apple.notificationsettings</string>
  <key>PayloadUUID</key>
  <string>72320632-4fdd-404d-ac87-55121892XXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
```
