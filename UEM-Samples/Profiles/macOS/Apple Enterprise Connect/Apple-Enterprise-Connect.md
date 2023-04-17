## Apple Enterprise Connect Custom XML Payloads ##

* Author Name:  Robert Terakedis (rterakedis@vmware.com)
* Date:  3/2/2017 
* Minimal/High Level Description:    Custom XML Payload to configure Apple Enterprise Connect.  
* Tested Version:   AirWatch version 9.0


Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
<dict>
    <key>PayloadType</key>
    <string>com.apple.Enterprise-Connect</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>PayloadIdentifier</key>
    <string>com.apple.Enterprise-Connect.5b4135a0-c87c-0133-5bc5-245e60d6b66b.test</string>
    <key>PayloadEnabled</key>
    <true />
    <key>PayloadUUID</key>
    <string>5b4135a0-c87c-0133-5bc5-245e60d6b66b</string>
    <key>PayloadDisplayName</key>
    <string>Enterprise Connect Settings</string>
    <key>adRealm</key>
    <string>YOUR.DOMAIN.REALM</string>
    <key>connectionCompletedScriptPath</key>
    <string>/Library/Scripts/EnterpriseConnect/shares.sh</string>
    <key>disableQuitMenu</key>
    <true/>
    <key>mountNetworkHomeDirectory</key>
    <false/>
    <key>syncLocalPassword</key>
    <true/>
</dict>
```