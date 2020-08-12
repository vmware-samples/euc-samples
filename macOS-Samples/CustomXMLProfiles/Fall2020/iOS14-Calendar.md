## iOS 14 Calendar ##

This payload includes:
* Per account VPN

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>CalDAVAccountDescription</key>
  <string>CalDAV Account</string>
  <key>CalDAVHostName</key>
  <string>example.com</string>
  <key>CalDAVPort</key>
  <integer>8443</integer>
  <key>CalDAVUseSSL</key>
  <true />
  <key>VPNUUID</key>
  <string>52a82cc3-3096-45ef-9ebd-45ac91723b14</string> <!--Example only-->
  <key>PayloadDisplayName</key>
  <string>CalDAV</string>
  <key>PayloadDescription</key>
  <string>CalDAVSettings</string>
  <key>PayloadIdentifier</key>
  <string>195c2047-813f-423e-b8c6-56a47a721b6e.CalDAV</string>
  <key>PayloadOrganization</key>
  <string></string>
  <key>PayloadType</key>
  <string>com.apple.caldav.account</string>
  <key>PayloadUUID</key>
  <string>562ecf6d-584b-4b4b-af5f-28b61160XXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
```
