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

> **NOTE**:  Microsoft has released guidance on the new system extensions here:   https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/mac-sysext-policies.  This document has not been validated against these new configurations as of yet.

### Custom Settings for Managed Preferences
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

### Kernel Extensions and Privacy Preferences
In Workspace ONE UEM, you need only click Add > Profile in the top right corner, and build a macOS Device profile. While we typically suggest only a single payload per profile, in this instance, you need multiple payloads for a single app. 

* The Kernel Extension payload whitelisting the Team ID: `UBF8T346G9`
* The Privacy Preferences payload for the bundle ID `com.microsoft.wdav` granting it an *Allow* for the `SystemPolicyAllFiles` entitlement.  The Code Requirement is `identifier "com.microsoft.wdav" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = UBF8T346G9`
