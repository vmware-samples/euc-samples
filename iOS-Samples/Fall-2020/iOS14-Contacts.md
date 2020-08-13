## iOS 14 Contacts ##

This payload includes:
* Per account VPN

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>CardDAVAccountDescription</key>
  <string>CardDAV</string>
  <key>CardDAVHostName</key>
  <string>example.com</string>
  <key>CardDAVPort</key>
  <integer>8843</integer>
  <key>CardDAVUseSSL</key>
  <true />
  <key>VPNUUID</key>
  <string>52a82cc3-3096-45ef-9ebd-45ac91723b14</string> <!--Example only-->
  <key>PayloadDisplayName</key>
  <string>CardDav</string>
  <key>PayloadDescription</key>
  <string>CardDAVSettings</string>
  <key>PayloadIdentifier</key>
  <string>195c2047-813f-423e-b8c6-56a47a721b6e.CardDav</string>
  <key>PayloadOrganization</key>
  <string></string>
  <key>PayloadType</key>
  <string>com.apple.carddav.account</string>
  <key>PayloadUUID</key>
  <string>65cc5690-d01a-4b5e-9a83-0d88c334XXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
```
