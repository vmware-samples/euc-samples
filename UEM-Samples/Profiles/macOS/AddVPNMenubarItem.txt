## Add the following 2 Custom XML Payloads in the same profile using the [+] to add the 2nd payload ##
## Requires a restart of SystemUIServer or a logout of the user's session.    If applying during DEP enrollment, ensure AwaitConfiguration is enabled ##

<dict>
    <key>PayloadDisplayName</key>
    <string>Show VPN on MenuBar - NetworkConnect</string>
    <key>PayloadEnabled</key>
    <true/>
    <key>PayloadIdentifier</key>
    <string>com.apple.networkConnect.51AC5EC0-2A1C-416E-BF1E-A93E20D97FE5</string>
    <key>PayloadType</key>
    <string>com.apple.networkConnect</string>
    <key>PayloadUUID</key>
    <string>51AC5EC0-2A1C-416E-BF1E-A93E20D97FE5</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>VPNShowStatus</key>
    <true/>
    <key>VPNShowTime</key>
    <true/>
</dict>


<dict>
    <key>PayloadDisplayName</key>
    <string>Show VPN on MenuBar - SystemUIServer</string>
    <key>PayloadEnabled</key>
    <true/>
    <key>PayloadIdentifier</key>
    <string>com.apple.networkConnect.28AF958C-C39D-49F8-99B3-357E986BF27F</string>
    <key>PayloadType</key>
    <string>com.apple.systemuiserver</string>
    <key>PayloadUUID</key>
    <string>28AF958C-C39D-49F8-99B3-357E986BF27F</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>menuExtras</key>
    <array>
           <string>/System/Library/CoreServices/Menu Extras/VPN.menu</string>
    </array>
</dict>