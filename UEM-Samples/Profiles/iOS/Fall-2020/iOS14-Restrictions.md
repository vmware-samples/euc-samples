## iOS 14 Restrictions ##

This payload includes:
* Allow app clips

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>allowAppClips</key>
  <false />
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
  <string>56238411-4d7b-45c5-a876-4dcdeae7XXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
```
