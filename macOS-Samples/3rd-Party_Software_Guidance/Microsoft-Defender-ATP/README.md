# Microsoft Defender ATP #
Deploying MS Defender ATP macOS with vmWare WorkspaceOne UEM

## Overview
- **Authors**: Robert Terakedis, Christian Rüppel
- **Email**: rterakedis@vmware.com, christian.rueppel@me.com
- **Date Created**: 2/12/2020
- **Supported Platforms**: WorkspaceOne UEM version 19.09
- **Tested on macOS Versions**: macOS Catalina (10.15.3)

## Purpose
If you want to distribute Microsoft Defender ATP for macOS via WorkspaceOne in an enterprise environment you need 2 plist at the end which you distribute via the custom settings in WS1 and which are located in the /Libray/Managed Preferences/. 
On the one hand you need the onboarding info, which contains the license for Defender ATP, on the other hand you need the configuration settings. In addition you have to define the system extension policy, kernel extension policy and the privacy preferences.

For the managed configuration settings you need the com.microsoft.wdav.plist
Sanitized plist/custom setting in xml:
```xml
<dict>
<key>PayloadType</key>
<string>com.microsoft.wdav</string>
<key>PayloadVersion</key>
<integer>1</integer>
<key>PayloadIdentifier</key>
<string>com.microsoft.wdav.D71143E9-8F41-47EE-8CD2-69495E82C6AC</string>
<key>PayloadEnabled</key>
<true/>
<key>PayloadUUID</key>
<string>D71143E9-8F41-47EE-8CD2-69495E82C6AC</string>
<key>PayloadDisplayName</key>
<string>WDATP configuration settings</string>
<key>AllowUserOverrides</key>
<false/>
<key>SendAllTelemetryEnabled</key>
<false/>
<key>antivirusEngine</key>
<dict>
<key>enableRealTimeProtection</key>
<true/>
<key>passiveMode</key>
<false/>
<key>exclusionsMergePolicy</key>
<string>admin_only</string>
</dict>
<key>cloudService</key>
<dict>
<key>enabled</key>
<true/>
<key>automaticSampleSubmission</key>
<false/>
<key>diagnosticLevel</key>
<string>required</string>
</dict>
<key>allowedThreats</key>
<dict>
<key>disallowedThreatActions</key>
<string>allow</string>
</dict>
<key>OrgId</key>
<string>xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx</string>
</dict>
```

For the onboarding info and licence you need the com.microsoft.wdav.atp.plist
Sanitized plist/custom setting in xml:
```xml
<dict>
<key>PayloadType</key>
<string>com.microsoft.wdav.atp</string>
<key>PayloadVersion</key>
<integer>1</integer>
<key>PayloadIdentifier</key>
<string>com.microsoft.wdav.atp.D71143E9-8F41-47EE-8CD2-69495E82C6AC</string>
<key>PayloadEnabled</key>
<true/>
<key>PayloadUUID</key>
<string>D71143E9-8F41-47EE-8CD2-69495E82C6AC</string>
<key>PayloadDisplayName</key>
<string>WDATP Onboarding</string>
<key>AllowUserOverrides</key>
<false/>
<key>SendAllTelemetryEnabled</key>
<false/>
<key>OrgId</key>
<string>xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx</string>
<key>OnboardingInfo</key>
<string>settings from your Defender ATP Admin center</string>
</dict>
```
Finally you can build a new profile for system extension policy, kernel extension policy and privacy preferences or you can include in one of your previous profile.
