## iOS 14 LDAP ##

This payload includes:
* Per account VPN

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>LDAPAccountDescription</key>
  <string>LDAP Account</string>
  <key>LDAPAccountHostName</key>
  <string>example.com</string>
  <key>LDAPAccountUseSSL</key>
  <true />
  <key>VPNUUID</key>
  <string>52a82cc3-3096-45ef-9ebd-45ac91723b14</string> <!--Example only-->
  <key>LDAPSearchSettings</key>
  <array>
    <dict>
      <key>LDAPSearchSettingDescription</key>
      <string>My Search</string>
      <key>LDAPSearchSettingScope</key>
      <string>LDAPSearchSettingScopeBase</string>
      <key>LDAPSearchSettingSearchBase</key>
      <string>O = My Company</string>
    </dict>
  </array>
  <key>PayloadDisplayName</key>
  <string>LDAP</string>
  <key>PayloadDescription</key>
  <string>LDAPSettings</string>
  <key>PayloadIdentifier</key>
  <string>195c2047-813f-423e-b8c6-56a47a721b6e.LDAP</string>
  <key>PayloadOrganization</key>
  <string></string>
  <key>PayloadType</key>
  <string>com.apple.ldap.account</string>
  <key>PayloadUUID</key>
  <string>f67af57f-fb84-4752-98f5-cddcaf17XXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
```
