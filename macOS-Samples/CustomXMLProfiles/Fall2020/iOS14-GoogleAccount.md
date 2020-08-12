## iOS 14 Google Account ##

This payload includes:
* Per account VPN

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>AccountName</key>
  <string>Google Account</string>
  <key>EmailAddress</key>
  <string>jdoe@example.com</string>
  <key>VPNUUID</key>
  <string>52a82cc3-3096-45ef-9ebd-45ac91723b14</string> <!--Example only-->
  <key>PayloadDisplayName</key>
  <string>Google Account</string>
  <key>PayloadDescription</key>
  <string>GoogleAccount</string>
  <key>PayloadIdentifier</key>
  <string>195c2047-813f-423e-b8c6-56a47a721b6e.Google Account</string>
  <key>PayloadOrganization</key>
  <string></string>
  <key>PayloadType</key>
  <string>com.apple.google-oauth</string>
  <key>PayloadUUID</key>
  <string>55494d9b-fd84-4e45-a071-2d349b0eXXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
```
