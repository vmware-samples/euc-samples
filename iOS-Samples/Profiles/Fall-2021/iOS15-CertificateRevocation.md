## iOS 15 Certificate Revocation ##

This is a new payload for revoking certificates.

This payload includes:
* Revoked certificates

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>EnabledForCerts</key>
    <array>
      <dict>
        <key>Algorithm</key>
        <string>sha256</string>
        <key>Hash</key>
        <data>HASHOFCERT</data> <!--The hash of the DER-encoding of the certificate’s subjectPublicKeyInfo.-->
      </dict>
    </array>
  <key>PayloadDescription</key>
  <string>Revokes certificates</string>
  <key>PayloadDisplayName</key>
  <string>Certificate Revocation settings</string>
  <key>PayloadIdentifier</key>
  <string>com.apple.security.certificaterevocation.8ECE5754-9FF5-4F2F-AB34-A8E83D2BXXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
  <key>PayloadType</key>
  <string>com.apple.security.certificaterevocation</string>
  <key>PayloadUUID</key>
  <string>8ECC5754-9FD5-4F2F-AB34-A8E83D2BC16F</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
```
