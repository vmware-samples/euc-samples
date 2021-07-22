## iOS 15 Restrictions ##

This payload includes:
* Require managed pasteboard
* Allow iCloud private relay
* Force on device translation

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>requireManagedPasteboard</key> <!--This field works in conjuction with the existing Managed Open In keys in the Restrictions payload UI-->
  <true />
  <key>allowCloudPrivateRelay</key>
  <false />
  <key>forceOnDeviceOnlyTranslation</key>
  <true />
  <key>PayloadDisplayName</key>
  <string>Restrictions</string>
  <key>PayloadDescription</key>
  <string>RestrictionSettings</string>
  <key>PayloadIdentifier</key>
  <string>195c2047-813f-423e-b8c6-56a47a721b6e.Restrictions</string>
  <key>PayloadOrganization</key>
  <string></string>
  <key>PayloadType</key>
  <string>com.apple.applicationaccess</string>
  <key>PayloadUUID</key>
  <string>56358411-4d7b-45c5-a876-43cdeae7XXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
```
