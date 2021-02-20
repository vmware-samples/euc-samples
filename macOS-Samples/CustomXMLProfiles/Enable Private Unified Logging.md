## Enable Private Data in Unified Logging - Custom XML for macOS ##

When viewing unified logging (via `log stream` or other related command), you'll note that data is occasionally obfuscated and displayed as `<private>`.   By sending this Custom XML to a device, macOS removes the obfuscation and displays more of the detail in the logging.

> This should be published as a Custom Settings payload in a macOS Device profile.


```XML
<dict>
      <key>PayloadDisplayName</key>
      <string>Enable ManagedClient Private Logging</string>
      <key>PayloadEnabled</key>
      <true/>
      <key>PayloadIdentifier</key>
      <string>com.apple.system.logging.982757D5-775E-4330-A5EF-089B3B5F4249</string>
      <key>PayloadType</key>
      <string>com.apple.system.logging</string>
      <key>PayloadUUID</key>
      <string>982757D5-775E-4330-A5EF-089B3B5F4249</string>
      <key>PayloadVersion</key>
      <integer>1</integer>
      <key>System</key>
      <dict>
        <key>Enable-Private-Data</key>
        <true/>
      </dict>
    </dict>
```

Some additional information as found by the MacAdmins Community:

* [Unified Logs: How to enable private data [cmdReporter]](https://www.cmdsec.com/unified-logs-enable-private-data/)