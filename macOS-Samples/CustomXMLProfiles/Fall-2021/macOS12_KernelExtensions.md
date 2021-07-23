## macOS 12 Kernel Extension ##

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
  <key>AllowUserOverrides</key>
  <true />
  <key>AllowNonAdminUserApproval</key> <!-- New key -->
  <false />
  <key>AllowedTeamIdentifiers</key>
  <array>
    <string>ABC123</string>
  </array>
  <key>AllowedKernelExtensions</key>
  <dict>
    <key>ABC123</key>
    <array>
      <string>com.my.app</string>
    </array>
  </dict>
  <key>PayloadDisplayName</key>
  <string>KernelExtension</string>
  <key>PayloadDescription</key>
  <string>KernelExtensionSettings</string>
  <key>PayloadOrganization</key>
  <string></string>
  <key>PayloadType</key>
  <string>com.apple.syspolicy.kernel-extension-policy</string>
  <key>PayloadUUID</key>
  <string>8b33e0f4-fb26-4b3d-af1e-e947c17XXXX</string> <!--Change last four values XXXX to random alphanumeric characters-->
  <key>PayloadVersion</key>
  <integer>1</integer>
  <key>PayloadIdentifier</key>
  <string>2e52a9bf-a4a8-4c06-bf31-bb7f43673a68.KernelExtension</string>
</dict>
```
