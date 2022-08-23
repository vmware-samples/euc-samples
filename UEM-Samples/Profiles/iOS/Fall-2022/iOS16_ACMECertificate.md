# iOS 16 ACME Certificate profile #

Paste the entire XML snippet (`<dict>...</dict>`) into the [Custom Settings payload](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/2011/iOS_Platform/GUID-AWT-PROFILECUSTOMSETTS.html) in Workspace ONE UEM. *Note that the payload must be configured with a valid ACME server that supports the following [draft RFC](https://datatracker.ietf.org/doc/draft-bweeks-acme-device-attest/).*

```xml
<dict>
    <key>PayloadDescription</key>
    <string>Generate ACME Certificates</string>
    <key>PayloadDisplayName</key>
    <string>ACME Certificate</string>
    <key>PayloadIdentifier</key>
    <string>FAB5B336-B76F-4DE9-A6AF-D957679EFBCF</string>
    <key>PayloadOrganization</key>
    <string></string>
    <key>PayloadType</key>
    <string>com.apple.security.acme</string>
    <key>PayloadUUID</key>
    <string>5A3F6F19-5470-48D1-A103-CD15AC42F31F</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>DirectoryURL</key>
    <string>valid_acme_server</string>
    <key>ClientIdentifier</key>
    <string>example_client_identifier</string>
    <key>KeySize</key>
    <integer>256</integer>
    <key>KeyType</key>
    <string>ECSECPrimeRandom</string>
    <key>HardwareBound</key>
    <true/>
    <key>Subject</key>
    <array>
        <array>
            <array>
                <string>C</string>
                <string>US</string>
            </array>
            <array>
                <string>O</string>
                <string>Example Inc.</string>
            </array>
            <array>
                <string>1.2.840.113635.100.6.99999.99999</string>
                <string>bar</string>
            </array>
        </array>
    </array>
    <key>SubjectAltName</key>
    <dict>
        <key>rfc822Name</key>
        <string></string>
        <key>dNSName</key>
        <string></string>
        <key>uniformResourceIdentifier</key>
        <string></string>
        <key>ntPrincipalName</key>
        <string></string>
    </dict>
    <key>ExtendedKeyUsage</key>
    <array>
        <string>1.3.6.1.5.5.7.3.2</string>
        <string>1.3.6.1.5.5.7.3.4</string>
    </array>
    <key>Attest</key>
    <true/>
</dict>
```

## Key Descriptions ##

| Key           | Type          | Presence | Description   |
|---------------|---------------|----------|---------------|
| `DirectoryURL` | string | required | Allow The directory URL of the ACME server. The URL must use the https scheme. Security Response installation by user. | 
| `ClientIdentifier` | string | required | A unique string identifying a specific device. The server may use this as a nonce to prevent issuing multiple certificates. This identifier also indicates to the ACME server that the device has access to a valid client identifier issued by the enterprise infrastructure. This can help the ACME server determine whether to trust the device. Though this is a relatively weak indication because of the risk that an attacker can intercept the client identifier. | 
| `KeySize` | integer | required | The valid values for 'KeySize' depend on the values of 'KeyType' and 'HardwareBound'. See those keys for specific requirements. |
| `KeyType` | string | required | The type of key pair to generate. <ul><li>'RSA': Specifies an RSA key pair. RSA key pairs must have a KeySize in the range [1024..4096] inclusive and a multiple of 8, and 'HardwareBound' must be false.</li><li>'ECSECPrimeRandom': Specifies a key pair on the P-192, P-256, P-384 or P-521 curves as defined in FIPS Pub 186-4. KeySize defines the particular curve, which must be 192, 256, 384 or 521. Hardware bound keys only support values of 256 and 384. Note that the key size is 521, not 512, even though the other key sizes are multiples of 64.</ul> |
| `HardwareBound` | boolean | required | <ul><li>If 'false', the private key isn't bound to the device.</li><li>If 'true', the private key is bound to the device. The Secure Enclave generates the key pair, and the private key is cryptographically entangled with a system key. This prevents the system from exporting the private key.</li> <li>If 'true', 'KeyType' must be 'ECSECPrimeRandom' and 'KeySize' must be 256 or 384.</li></ul> |
| `Subject` | array | required |   The device requests this subject for the certificate that the ACME server issues. The ACME server may override or ignore this field in the certificate it issues. <ul><li>The representation of a X.500 name represented as an array of OID and value. For example, /C=US/O=Apple Inc./CN=foo/1.2.5.3=bar corresponds to:[ [ [”C”, “US”] ], [ [”O”, “Apple Inc.”] ], ..., [ [ “1.2.5.3”, “bar” ] ] ]</li><li>Dotted numbers can represent OIDs , with shortcuts for country (C), locality (L), state (ST), organization (O), organizational unit (OU), and common name (CN).</li> |
| `SubjectAltName` | dictionary | optional | The Subject Alt Name that the device requests for the certificate that the ACME server issues. The ACME server may override or ignore this field in the certificate it issues. |
| `UsageFlags` | integer | optional | This value is a bit field.<ul><li>Bit '0x01' indicates digital signature.</li></li>Bit '0x10' indicates key agreement.</li></ul> The device requests this key for the certificate that the ACME server issues. The ACME server may override or ignore this field in the certificate it issues. |
| `ExtendedKeyUsage` | array | optional | The value is an array of strings. Each string is an OID in dotted notation. For instance, [”1.3.6.1.5.5.7.3.2”, “1.3.6.1.5.5.7.3.4”] indicates client authentication and email protection. The device requests this field for the certificate that the ACME server issues The ACME server may override or ignore this field in the certificate it issues. |
| `Attest` | boolean | optional |  If 'true', the device provides attestations describing the device and the generated key to the ACME server. The server can use the attestations as strong evidence that the key is bound to the device, and that the device has properties listed in the attestation. The server can use that as part of a trust score to decide whether to issue the requested certificate. When 'Attest' is 'true', 'HardwareBound' must also be 'true'. |
