## iOS 14 Exchange ##

This payload includes:
* Override previous users passcode
* Per account VPN

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>EmailAddress</key>
  <string>jdoe@example.com</string>
  <key>UserName</key>
  <string>example.com\jdoe</string>
  <key>PayloadDisplayName</key>
  <string>Exchange ActiveSync</string>
  <key>OverridePreviousPassword</key>
  <true />
  <key>VPNUUID</key>
  <string>52a82cc3-3096-45ef-9ebd-45ac91723b14</string> <!--Example only-->
  <key>Host</key>
  <string>Hostname</string>
  <key>PayloadDescription</key>
  <string>ExchangeActiveSyncSettings</string>
  <key>PayloadIdentifier</key>
  <string>195c2047-813f-423e-b8c6-56a47a721b6e.Exchange ActiveSync</string>
  <key>PayloadOrganization</key>
  <string></string>
  <key>PayloadType</key>
  <string>com.apple.eas.account</string>
  <key>PayloadUUID</key>
  <string>26a7aaa7-c5cf-4d36-94d3-731b8b3dXXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
```
