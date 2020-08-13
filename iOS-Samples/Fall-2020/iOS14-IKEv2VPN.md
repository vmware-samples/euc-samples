## iOS 14 Per-app VPN ##

This payload includes:
* Associated and excluded domains

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>PayloadDescription</key>
  <string>Configures VPN settings, including authentication.</string>
  <key>PayloadDisplayName</key>
  <string>VPN (VPN Configuration)</string>
  <key>PayloadIdentifier</key>
  <string>195c2047-813f-423e-b8c6-56a47a721b6e.VPN</string>
  <key>PayloadOrganization</key>
  <string></string>
  <key>PayloadType</key>
  <string>com.apple.vpn.managed.applayer</string>
  <key>PayloadUUID</key>
  <string>eb37955d-8492-4d8c-9d0c-fc57b9503744</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
  <key>UserDefinedName</key>
  <string>VPN Configuration</string>
  <key>VPNUUID</key>
  <string>dd3a392c-5db4-4bd3-b300-89ac8569f8e0</string>
  <key>MailDomains</key>
  <array>
    <string>example.com</string>
  </array>
  <key>ContactsDomains</key>
  <array>
    <string>example.com</string>
  </array>
  <key>VPNType</key>
  <string>IKEv2</string>
  <key>IPv4</key>
  <dict>
    <key>OverridePrimary</key>
    <integer>0</integer>
  </dict>
  <key>IKEv2</key>
  <dict>
    <key>OnDemandMatchAppEnabled</key>
    <true />
    <key>RemoteAddress</key>
    <string>example.com</string>
    <key>LocalIdentifier</key>
    <string>com.example.ikev2</string>
    <key>RemoteIdentifier</key>
    <string>com.example2.ikev2</string>
    <key>AuthenticationMethod</key>
    <string>SharedSecret</string>
    <key>ExtendedAuthEnabled</key>
    <integer>0</integer>
    <key>MTU</key>
    <integer>1280</integer> <!--New feature!-->
    <key>DeadPeerDetectionRate</key>
    <string>Low</string>
    <key>DisableRedirect</key>
    <integer>0</integer>
    <key>DisableMOBIKE</key>
    <integer>0</integer>
    <key>UseConfigurationAttributeInternalIPSubnet</key>
    <integer>0</integer>
    <key>NATKeepAliveOffloadEnable</key>
    <integer>0</integer>
    <key>EnablePFS</key>
    <integer>0</integer>
    <key>ChildSecurityAssociationParameters</key>
    <dict>
      <key>EncryptionAlgorithm</key>
      <string>AES-256</string>
      <key>IntegrityAlgorithm</key>
      <string>SHA2-256</string>
      <key>DiffieHellmanGroup</key>
      <integer>14</integer>
      <key>LifeTimeInMinutes</key>
      <integer>1440</integer>
      <key>EnableFallback</key>
      <integer>0</integer>
    </dict>
    <key>IKESecurityAssociationParameters</key>
    <dict>
      <key>EncryptionAlgorithm</key>
      <string>AES-256</string>
      <key>IntegrityAlgorithm</key>
      <string>SHA2-256</string>
      <key>DiffieHellmanGroup</key>
      <integer>14</integer>
      <key>LifeTimeInMinutes</key>
      <integer>1440</integer>
      <key>EnableFallback</key>
      <integer>0</integer>
    </dict>
  </dict>
  <key>IPv4</key>
  <dict>
    <key>OverridePrimary</key>
    <integer>1</integer>
  </dict>
  <key>Proxies</key>
  <dict />
  <key>VPN</key>
  <dict>
    <key>ProviderType</key>
    <string>app-proxy</string>
  </dict>
</dict>
```
