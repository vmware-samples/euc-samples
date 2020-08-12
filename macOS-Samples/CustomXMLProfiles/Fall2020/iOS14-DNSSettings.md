## iOS 14 DNS Settings##

This is a net new payload for configuring encrypted DNS settings.

This payload includes:
* DNS settings dictionary

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
    <key>DNSSettings</key>
    <dict>
        <key>DNSProtocol</key>
        <string>TLS</string> <!--Possible values: HTTPS, TLS-->
        <key>ServerAddresses</key>
        <array>
            <string>216.3.128.12</string> <!-- can be a mixture of IPv4 and IPv6 addresses, this is a random one -->
        </array>
        <key>ServerName</key> <!--This key must be present only if the DNSProtocol is TLS-->
        <string>myServerName</string>
        <key>ServerURL</key>
        <string>https://myServerName.com</string> <!--This key must be present only if the DNSProtocol is HTTPS-->
        <key>SupplementalMatchDomains</key>
         <array>
            <string>example.domain.com</string>
        </array>
    </dict>
    <key>OnDemandRules</key>
    <array>
        <dict>
            <key>Action</key>
            <string>Connect</string> <!--Possible values: Connect, Disconnect, EvaluateConnection-->
        </dict>
        <dict>
            <key>ActionParameters</key>
            <dict>
                <key>DomainAction</key>
                <string>Never Connect</string> <!--Possible values: NeverConnect, ConnectIfNeeded-->
                <key>Domains</key>
                <array>
                    <string>www.mydomain.com</string>
                </array>
            </dict>
        </dict>
        <dict>
            <key>DNSDomainMatch</key>
            <array>
                <string>domainstobe.matched.com</string>
            </array>
        </dict>
        <dict>
            <key>DNSServerAddressMatch</key>
            <array>
                <string>serveraddress.matched.domain.com</string>
            </array>
        </dict>
        <dict>
            <key>InterfaceTypeMatch</key>
            <string>Ethernet</string> <!--Possible values: Ethernet, WiFi, Cellular-->
        </dict>
        <dict>
            <key>SSIDMatch</key>
            <array>
                <string>thisisanSSID</string>
            </array>
        </dict>
        <dict>
            <key>URLStringProbe</key>
            <string>www.urltoprobe.com</string>
        </dict>
    </array>
    <key>ProhibitDisablement</key>
    <false />
    <key>PayloadDisplayName</key>
    <string>DNSSettings</string>
    <key>PayloadDescription</key>
    <string>DNSSettings</string>
    <key>PayloadIdentifier</key>
    <string>195c2047-813f-423e-b8c6-56a47a721b6e.DNSSettings</string>
    <key>PayloadOrganization</key>
    <string></string>
    <key>PayloadType</key>
    <string>com.apple.dnsSettings.managed</string>
    <key>PayloadUUID</key>
    <string>56238411-4d7b-45c5-a876-4d3geae7XXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
    <key>PayloadVersion</key>
    <integer>1</integer>
</dict>

```
