* Author Name:  Robert Terakedis (rterakedis@vmware.com)
* Date:  11/30/2016 
*  Minimal/High Level Description:    Custom XML Payloads to customize the Microsoft Office 2016 Experience.  Paste each individual section into a separate Custom XML payload.  Adapted from information available at https://docs.google.com/spreadsheets/d/1ESX5td0y0OP3jdzZ-C2SItm-TUi-iA_bcHCBvaoCumw/edit#gid=0
* Tested Version:   AirWatch version 9.0


## REMOVE FIRST-RUN SPLASH SCREENS ##

### EXCEL: ###
Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
    <dict>
        <key>PayloadType</key>
        <string>com.microsoft.Excel</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
        <key>PayloadIdentifier</key>
        <string>com.apple.mdm.20EX23025-MAC.local.4d89f680-c87b-0133-5bc4-245e60d6b66b.alacarte.macosxrestrictions.5b4135a0-c87c-0133-5bc5-245e60d6b66b.new</string>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadUUID</key>
        <string>2b81305b-6f5b-5cdb-a00f-cb2db73d1249</string>
        <key>PayloadDisplayName</key>
        <string>Excel First Launch Settings</string>
        <key>kSubUIAppCompletedFirstRunSetup1507</key>
        <true />
    </dict>
```


### ONENOTE: ###
Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
    <dict>
        <key>PayloadType</key>
        <string>com.microsoft.onenote.mac</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
        <key>PayloadIdentifier</key>
        <string>com.apple.mdm.20EX23025-MAC.local.4d89f680-c87b-0133-5bc4-245e60d6b66b.alacarte.macosxrestrictions.5b4135a0-c87c-0133-5bc5-245e60d6b66b.dashboard</string>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadUUID</key>
        <string>a535ab67-4684-e07f-1d11-4c5bf5025540</string>
        <key>PayloadDisplayName</key>
        <string>Onenote First Launch</string>
        <key>ONWhatsNewShownItemIds</key>
        <array>
          <integer>18</integer>
          <integer>19</integer>
          <integer>17</integer>
          <integer>16</integer>
          <integer>5</integer>
          <integer>10</integer>
          <integer>1</integer>
          <integer>11</integer>
          <integer>13</integer>
          <integer>4</integer>
          <integer>9</integer>
          <integer>14</integer>
          <integer>2</integer>
          <integer>7</integer>
          <integer>12</integer>
        </array>
        <key>kSubUIAppCompletedFirstRunSetup1507</key>
        <true />
    </dict>
```


### OUTLOOK: ### 
Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
    <dict>
        <key>PayloadType</key>
        <string>com.microsoft.Outlook</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
        <key>PayloadIdentifier</key>
        <string>com.apple.mdm.20EX23025-MAC.local.4d89f680-c87b-0133-5bc4-245e60d6b66b.alacarte.macosxrestrictions.5b4135a0-c87c-0133-5bc5-245e60d6b66b.systemuiserver</string>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadUUID</key>
        <string>0144d2d8-48c3-039f-e1dd-d1587cf8b0f5</string>
        <key>PayloadDisplayName</key>
        <string>Outlook First Launch</string>
        <key>kSubUIAppCompletedFirstRunSetup1507</key>
        <true />
        <key>FirstRunExperienceCompletedO15</key>
        <true />
    </dict>
```


### POWERPOINT: ### 
Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
    <dict>
        <key>PayloadType</key>
        <string>com.microsoft.PowerPoint</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
        <key>PayloadIdentifier</key>
        <string>com.apple.mdm.20EX23025-MAC.local.4d89f680-c87b-0133-5bc4-245e60d6b66b.alacarte.macosxrestrictions.5b4135a0-c87c-0133-5bc5-245e60d6b66b.DiscRecording</string>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadUUID</key>
        <string>e11732b2-d90c-69c4-9a62-6ae632baca08</string>
        <key>PayloadDisplayName</key>
        <string>PowerPoint First Launch Settings</string>
        <key>kSubUIAppCompletedFirstRunSetup1507</key>
        <true />
    </dict>
```


### WORD: ### 
Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
    <dict>
        <key>PayloadType</key>
        <string>com.microsoft.Word</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
        <key>PayloadIdentifier</key>
        <string>com.apple.mdm.20EX23025-MAC.local.4d89f680-c87b-0133-5bc4-245e60d6b66b.alacarte.macosxrestrictions.5b4135a0-c87c-0133-5bc5-245e60d6b66b.finder</string>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadUUID</key>
        <string>23759084-f25b-d9b2-4b8f-05936dac333c</string>
        <key>PayloadDisplayName</key>
        <string>Word First Launch Settings</string>
        <key>kSubUIAppCompletedFirstRunSetup1507</key>
        <true />
    </dict>
```


## FORCE AUTOMATIC AUTOUPDATES ##

### AUTOUPDATE: ###

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
    <dict>
        <key>PayloadContent</key>
        <dict>
            <key>com.microsoft.autoupdate2</key>
            <dict>
                <key>Forced</key>
                <array>
                    <dict>
                        <key>mcx_preference_settings</key>
                        <dict>
                            <key>DisableInsiderCheckbox</key>
                            <true/>
                            <key>HowToCheck</key>
                            <string>Automatic</string>
                            <key>WhenToCheck</key>
                            <integer>1</integer>
                        </dict>
                    </dict>
                </array>
            </dict>
        </dict>
        <key>PayloadEnabled</key>
        <true/>
        <key>PayloadIdentifier</key>
        <string>18C14A40-FFB1-4C0D-9598-FD41D4BE9247</string>
        <key>PayloadType</key>
        <string>com.apple.ManagedClient.preferences</string>
        <key>PayloadUUID</key>
        <string>18C14A40-FFB1-4C0D-9598-FD41D4BE9247</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
    </dict>
```