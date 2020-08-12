## iOS 14 Subscribed Calendars ##

This payload includes:
* Per account VPN

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>SubCalAccountHostName</key>
  <string>example.com</string>
  <key>SubCalAccountUseSSL</key>
  <false />
  <key>VPNUUID</key>
  <string>52a82cc3-3096-45ef-9ebd-45ac91723b14</string> <!--Example only-->
  <key>PayloadDisplayName</key>
  <string>Subscribed Calendars</string>
  <key>PayloadDescription</key>
  <string>SubscribedCalendarsSettings</string>
  <key>PayloadIdentifier</key>
  <string>195c2047-813f-423e-b8c6-56a47a721b6e.Subscribed Calendars</string>
  <key>PayloadOrganization</key>
  <string></string>
  <key>PayloadType</key>
  <string>com.apple.subscribedcalendar.account</string>
  <key>PayloadUUID</key>
  <string>05551e90-2900-4e48-b1b7-4c5e2351XXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
```
