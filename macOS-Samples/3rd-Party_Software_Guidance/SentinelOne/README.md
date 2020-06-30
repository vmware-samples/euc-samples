# SentinelOne

## Overview

- **Authors**: Paul Evans
- **Email**: pevans@vmware.com
- **Date Created**: 2020-06-24
- **Supported Platforms**: Workspace ONE UEM 2004
- **Tested on macOS Versions**: macOS Catalina

## Purpose

Install the SentinelOne agent via unattended installation using Workspace ONE UEM.

1) Deploy the Kernel Extension profile for the SentinelOne Kernel Extension.
2) Download the SentinelOne installer package for macOS (generally *SentinelAgent\_macos\_\<version\>.pkg*)
3) Parse the installer with the [Workspace ONE Admin Assistant](https://awagent.com/AdminAssistant/VMwareAirWatchAdminAssistant.dmg)
4) Modify the generated plist file as instructed.
5) Upload the pkg, plist, and icon to Workspace ONE UEM as an Internal App (Apps & Books > Native > Internal)
6) In the __Scripts__ tab, add the Preinstall script described.
7) Configure any remaining deployment settings and Assign the app as appropriate.

## Kernel Extension Profile for the SentinelOne KEXT

Workspace ONE administrators should deliver a Kernel Extension Policy payload to macOS 10.13.2 and later devices in order to allow the SentinelOne kernel extension to run.  To do this, perform the following (or optionally add the Team ID and Bundle ID to an existing profile):

1) Click **Add > Profile > macOS > Device** and complete the General information
2) Select the **Kernel Extension Policy** payload an click configure
3) Complete the profile as necessary, and include the following information in the *Allowed Kernel Extensions* list:
  * Team ID: 4AYE5J54KN
  * Bundle ID: com.sentinelone.sentinel-kext

> **NOTE:** It is recommended to deploy the KEXT policy to eligible devices *BEFORE* deploying the SentinelOne installer.

## Modify PkgInfo Plist File

This document will demonstrate how to install SentinelOne by staging the com.sentinelone.registration-token file on the target macOS device, pre-loaded with the necessary registration key, and then running the SentinelOne installer pkg utilizing that information.  The first step is to add an ```installs``` key and array to the plist file so Workspace ONE will properly identify when SentinelOne is installed.

```XML
<key>installs</key>
	<array>
		<dict>
			<key>CFBundleIdentifier</key>
			<string>com.sentinelone.sentinel-agent</string>
			<key>CFBundleName</key>
			<string>sentinel-agent</string>
			<key>CFBundleShortVersionString</key>
			<string>3.6.1</string>
			<key>CFBundleVersion</key>
			<string>2964</string>
			<key>path</key>
			<string>/Library/Sentinel/sentinel-agent.bundle/Contents/MacOS/SentinelAgent.app/</string>
			<key>type</key>
			<string>application</string>
			<key>version_comparison_key</key>
			<string>CFBundleShortVersionString</string>
		</dict>
	</array>
```

> **NOTE:** You will need to replace the *CFBundleShortVersionString* and *CFBundleVersion* values in the installs array if those are different for the particular version of the app you're deploying.  You can alternatively generate these values by exporting **SentinelAgent.app** from the installer package (using an app such as [Suspicious Package](https://mothersruin.com/software/SuspiciousPackage/)) and running it through the Workspace ONE Admin Assistant app.  The plist generated in that instance will contain the appropriate *installs* array information.

## Modify Preinstall Script for Internal App

In order to properly stage the com.sentinelone.registration-token file, you must add a **Preinstall** script to the deployment. Under the Scripts tab when configuring the application deployment, you must paste something similar to the following in the Preinstall Script textbox. Be sure to replace the *REGISTRATION_TOKEN* with details relevant to your own company's installer.

```BASH
#!/bin/sh
/bin/echo "REGISTRATION_TOKEN" > "/Library/Application Support/AirWatch/Data/Munki/Managed Installs/Cache/com.sentinelone.registration-token"
```

## Required Changes/Updates

None

## Change Log

- 2020-06-24: Created Initial File
