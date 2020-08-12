* **Author Name:**  Robert Terakedis (rterakedis@vmware.com)
* **Date:**  11/30/2016 
* **Updated:** 10/2/2018 
* **Minimal/High Level Description:**    Custom XML Payloads to customize the Microsoft Office 2016/2019 Experience.  Paste each individual section into a separate Custom XML payload.  Adapted from information available at https://docs.google.com/spreadsheets/d/1ESX5td0y0OP3jdzZ-C2SItm-TUi-iA_bcHCBvaoCumw/edit#gid=0
* **Tested Version(s):**   AirWatch version 9.0, Workspace ONE UEM 9.7


## CUSTOMIZE OFFICE OVERALL CONFIGURATIONS ##

```xml
    <dict>
        <key>PayloadType</key>
        <string>com.microsoft.office</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
        <key>PayloadIdentifier</key>
        <string>com.microsoft.office.FF71692A-A039-4354-AFAA-123BEE444F56</string>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadUUID</key>
        <string>FF71692A-A039-4354-AFAA-123BEE444F56</string>
        <key>PayloadDisplayName</key>
        <string>Office Sign-In Configuration</string>
        <key>OfficeAutoSignIn</key>
        <true />
        <key>kCUIThemePreferencesThemeKeyPath</key>
        <integer>2</integer>
        <key>OfficeActivationEmailAddress</key>
        <string>{EmailAddress}</string>
        <key>DefaultEmailAddressOrDomain</key>
        <string>{EmailAddress}</string>
        <key>DefaultsToLocalOpenSave</key>
        <true />
        <key>ShowDocStageOnLaunch</key>
        <false />
        <key>ShowWhatsNewOnLaunch</key>
        <false />
        <key>VisualBasicMacroExecutionState</key>
        <string>DisabledWithWarnings</string>
        <key>TermsAccepted1809</key>
        <true />
    </dict>
```

**NOTE** There are also additional settings related to Visual Basic Security Controls as documented in the [Support Bulletin regarding Office 2016/2019 VB Security Controls](https://macadmins.software/docs/VBSecurityControls.pdf)


## CONFIGURE INDIVIDUAL OFFICE APP SETTINGS ##

### EXCEL: ###
Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
    <dict>
        <key>PayloadType</key>
        <string>com.microsoft.Excel</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
        <key>PayloadIdentifier</key>
        <string>com.microsoft.Excel.2b81305b-6f5b-5cdb-a00f-cb2db73d1249</string>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadUUID</key>
        <string>2b81305b-6f5b-5cdb-a00f-cb2db73d1249</string>
        <key>PayloadDisplayName</key>
        <string>Excel First Launch Settings</string>
        <key>kSubUIAppCompletedFirstRunSetup1507</key>
        <true />
        <key>SendASmileEnabled</key>
        <false />
        <key>SendAllTelemetryEnabled</key>
        <false />
        <key>PII_And_Intelligent_Services_Preference</key>
        <true />
        <key>kFREIntelligenceServicesConsentV2Key</key>
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
        <string>com.microsoft.onenote.mac.a535ab67-4684-e07f-1d11-4c5bf5025540</string>
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
        <key>SendASmileEnabled</key>
        <false />
        <key>SendAllTelemetryEnabled</key>
        <false />
        <key>PII_And_Intelligent_Services_Preference</key>
        <true />
        <key>kFREIntelligenceServicesConsentV2Key</key>
        <true />
    </dict>
```


### OUTLOOK: ### 
Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.   This snippet removes first run screens and ALSO locks down the import/export functionality in the app.

```xml
    <dict>
        <key>PayloadType</key>
        <string>com.microsoft.Outlook</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
        <key>PayloadIdentifier</key>
        <string>com.microsoft.Outlook.58506E2D-BF2D-4169-8CCD-83095654C4E2</string>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadUUID</key>
        <string>58506E2D-BF2D-4169-8CCD-83095654C4E2</string>
        <key>PayloadDisplayName</key>
        <string>Outlook First Launch</string>
        <key>kSubUIAppCompletedFirstRunSetup1507</key>
        <true />
        <key>FirstRunExperienceCompletedO15</key>
        <true />
        <key>DisableImport</key>
        <true />
        <key>DisableExport</key>
        <true />
        <key>HideFoldersOnMyComputerRootInFolderList</key>
        <true />
        <key>AutomaticallyDownloadExternalContent</key>
        <integer>1</integer>
        <key>SendASmileEnabled</key>
        <false />
        <key>SendAllTelemetryEnabled</key>
        <false />
        <key>PII_And_Intelligent_Services_Preference</key>
        <true />
        <key>kFREIntelligenceServicesConsentV2Key</key>
        <true />
        <key>TrustO365AutodiscoverRedirect</key>
        <true />
        <key>o365GroupsOobePromoTriggeredPref</key>
        <true />
        <key>googlePromoTriggeredPref</key>
        <true />
        <key>DefaultEmailAddressOrDomain</key>
        <string>{EmailAddress}</string>
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
        <string>com.microsoft.PowerPoint.e11732b2-d90c-69c4-9a62-6ae632baca08</string>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadUUID</key>
        <string>e11732b2-d90c-69c4-9a62-6ae632baca08</string>
        <key>PayloadDisplayName</key>
        <string>PowerPoint First Launch Settings</string>
        <key>kSubUIAppCompletedFirstRunSetup1507</key>
        <true />
        <key>SendASmileEnabled</key>
        <false />
        <key>SendAllTelemetryEnabled</key>
        <false />
        <key>PII_And_Intelligent_Services_Preference</key>
        <true />
        <key>kFREIntelligenceServicesConsentV2Key</key>
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
        <string>com.microsoft.Word.23759084-f25b-d9b2-4b8f-05936dac333c</string>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadUUID</key>
        <string>23759084-f25b-d9b2-4b8f-05936dac333c</string>
        <key>PayloadDisplayName</key>
        <string>Word First Launch Settings</string>
        <key>kSubUIAppCompletedFirstRunSetup1507</key>
        <true />
        <key>SendASmileEnabled</key>
        <false />
        <key>SendAllTelemetryEnabled</key>
        <false />
        <key>PII_And_Intelligent_Services_Preference</key>
        <true />
        <key>kFREIntelligenceServicesConsentV2Key</key>
        <true />
    </dict>
```

## CONTROL ONEDRIVE BEHAVIOR ##

Based on [Configure Files On-Demand for Mac](https://docs.microsoft.com/en-us/OneDrive/files-on-demand-mac)

Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

### STANDALONE ONEDRIVE: ###
```xml
    <dict>
        <key>PayloadContent</key>
        <dict>
            <key>com.microsoft.OneDrive</key>
            <dict>
                <key>Forced</key>
                <array>
                    <dict>
                        <key>mcx_preference_settings</key>
                        <dict>
                            <key>DisablePersonalSync</key>
                            <false />
                            <key>HideDockIcon</key>
                            <true />
                            <key>DefaultToBusinessFRE</key>
                            <true />
                            <key>OpenAtLogin</key>
                            <true />
                            <key>FilesOnDemandPolicy</key>
                            <true />
                            <key>FilesOnDemandEnabled</key>
                            <true />
                            <key>IsHydrationToastAllowed</key>
                            <true />
                        </dict>
                    </dict>
                </array>
            </dict>
        </dict>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadIdentifier</key>
        <string>com.apple.ManagedClient.preferences.ADB6CD6A-93D1-4997-8BAD-076FC85F1BEE</string>
        <key>PayloadType</key>
        <string>com.apple.ManagedClient.preferences</string>
        <key>PayloadUUID</key>
        <string>ADB6CD6A-93D1-4997-8BAD-076FC85F1BEE</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
    </dict>
```

### MAC APP STORE ONEDRIVE: ###
```xml
    <dict>
        <key>PayloadContent</key>
        <dict>
            <key>com.microsoft.OneDrive-mac</key>
            <dict>
                <key>Forced</key>
                <array>
                    <dict>
                        <key>mcx_preference_settings</key>
                        <dict>
                            <key>DisablePersonalSync</key>
                            <false />
                            <key>HideDockIcon</key>
                            <true />
                            <key>DefaultToBusinessFRE</key>
                            <true />
                            <key>OpenAtLogin</key>
                            <true />
                            <key>FilesOnDemandPolicy</key>
                            <true />
                            <key>FilesOnDemandEnabled</key>
                            <true />
                            <key>IsHydrationToastAllowed</key>
                            <true />
                        </dict>
                    </dict>
                </array>
            </dict>
        </dict>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadIdentifier</key>
        <string>com.apple.ManagedClient.preferences.D5797142-AD7A-4CCD-88D1-FA85B22CC18D</string>
        <key>PayloadType</key>
        <string>com.apple.ManagedClient.preferences</string>
        <key>PayloadUUID</key>
        <string>D5797142-AD7A-4CCD-88D1-FA85B22CC18D</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
    </dict>
```

Note there is an additional key with this payload for Hydration Disallowed Apps:

```xml
    <key>HydrationDisallowedApps</key>
    <string> [{"ApplicationId":"appId","MaxBundleVersion":"1.1","MaxBuildVersion":"1.0"}, 
            {"ApplicationId":"appId2","MaxBundleVersion":"3.2","MaxBuildVersion":"2.0"},]]</string>
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
                            <true />
                            <key>HowToCheck</key>
                            <string>AutomaticDownload</string>
                            <key>UpdateCheckFrequency</key>
                            <integer>120</integer>
                            <key>DisableInsiderCheckbox</key>
                            <false />
                            <key>EnableCheckForUpdatesButton</key>
                            <true />
                            <key>StartDaemonOnAppLaunch</key>
                            <true />
                        </dict>
                    </dict>
                </array>
            </dict>
        </dict>
        <key>PayloadEnabled</key>
        <true />
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



### MICROSOFT ERROR REPORTING: ### 
Paste the entire XML snippet (`<dict>...</dict>`) into the Custom XML payload in Workspace ONE UEM.

```xml
    <dict>
        <key>PayloadType</key>
        <string>com.microsoft.errorreporting</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
        <key>PayloadIdentifier</key>
        <string>com.microsoft.errorreporting.4E6D26FD-2FC9-4E90-9B13-E26C99F01DBC</string>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadUUID</key>
        <string>4E6D26FD-2FC9-4E90-9B13-E26C99F01DBC</string>
        <key>PayloadDisplayName</key>
        <string>MS Error Reporting Settings</string>
        <key>IsAttachedEnabled</key>
        <false />
        <key>IsStoreLastCrashEnabled</key>
        <false />
    </dict>
```

AND...

```xml
    <dict>
        <key>PayloadType</key>
        <string>com.microsoft.Office365ServiceV2</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
        <key>PayloadIdentifier</key>
        <string>com.microsoft.Office365ServiceV2.D54021CB-8C16-4FB9-8210-11EE7F0CE23D</string>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadUUID</key>
        <string>D54021CB-8C16-4FB9-8210-11EE7F0CE23D</string>
        <key>PayloadDisplayName</key>
        <string>MS Telemetry Settings</string>
        <key>SendAllTelemetryEnabled</key>
        <false />
    </dict>
```

AND...

```xml
    <dict>
        <key>PayloadType</key>
        <string>com.microsoft.autoupdate.fba</string>
        <key>PayloadVersion</key>
        <integer>1</integer>
        <key>PayloadIdentifier</key>
        <string>com.microsoft.autoupdate.fba.5E1E6FDC-564E-4C11-BC98-9CDB6A461E8E</string>
        <key>PayloadEnabled</key>
        <true />
        <key>PayloadUUID</key>
        <string>5E1E6FDC-564E-4C11-BC98-9CDB6A461E8E</string>
        <key>PayloadDisplayName</key>
        <string>MS Telemetry Settings for AutoUpdate</string>
        <key>SendAllTelemetryEnabled</key>
        <false />
    </dict>
```