# Profiles for CIS Benchmark 
### (https://www.cisecurity.org/cis-benchmarks/)

## Overview

- **Authors**: Matt Zaske
- **Email**: mzaske@vmware.com
- **Date Created**: 6/9/2022
- **Supported Platforms**: Workspace ONE UEM v2203
- **Tested on macOS Versions**: macOS Big Sur

## Custom Profile Detail

The following requirements can be achieved using Custom Settings profiles with Workspace ONE UEM:

- 2.2.1 & 2.2.2 - Enable "Set time and date automatically" & Ensure time set is within appropriate limits: https://github.com/vmware-samples/euc-samples/blob/master/UEM-Samples/Profiles/macOS/Set_NTP_Server.md
- 2.3.3 - Familiarize users with screen lock tools or corner to Start Screen Saver: Hot Corner Setup.xml
- 2.5.2.2 & 2.5.2.3 - Enable Firewall & Enable Firewall Stealth Mode: CIS-firewall.xml
- 2.10 - Enable Secure Keyboard Entry in terminal.app: CIS-TerminalSecureKeyboard.xml
- 2.13 - Review Siri Settings: CIS-DisableSiri.xml & CIS-DisableSiriMenubar.xml
- 4.1 - Disable Bonjour advertising service: CIS-DisableBonjourAds.xml
- 6.1.4 - Disable "Allow guests to connect to shared folders: CIS-AFSGuestDisable.xml
- 6.3 - Disable the automatic run of safe files in Safari: CIS-DisableSafariAutoRun.xml

## Built-In Profile Detail

The following requirements can be achieved using standard device profiles with Workspace ONE UEM:

- Software Update:
  - 1.1 Verify all Apple provided software is current
  - 1.2 Enable Auto Update
  - 1.3 Enable Download new updates when available
  - 1.4 Enable app update installs
  - 1.5 Enable system data files and security updates install
  - 1.6 Enable macOS update installs
- Login Window
  - 2.3.1 Set an inactivity interval of 20 minutes or less for the screen saver 
  - 5.8 Disable automatic login
  - 5.13 Create a custom message for the Login Screen
  - 5.15 Do not enter a password-related hint
  - 5.16 Disable Fast User Switching
  - 6.1.1 Display login window as name and password
  - 6.1.2 Disable "Show password hints"
  - 6.1.3 Disable guest account login
- Restrictions
  - 2.4.10 Disable Content Caching
  - 2.4.12 Ensure AirDrop is Disabled
  - 2.6.2 iCloud keychain
  - 2.6.3 iCloud Drive
  - 2.6.4 iCloud Drive Document and Desktop sync
- Disk Encryption
  - 2.5.1.1 Enable FileVault
  - 2.5.1.2 Ensure all user storage APFS volumes are encrypted
  - 2.5.1.3 Ensure all user storage CoreStorage volumes are encrypted
- Security & Privacy
  - 2.5.2.1 Enable Gatekeeper
  - 2.5.5 Disable sending diagnostic and usage data to Apple
  - 5.9 Require a password to wake the computer from sleep or screen saver
- Passcode OR SSO Extension (AD Password Policy)
  - 5.2.1 Configure account lockout threshold
  - 5.2.2 Set a minimum password length
  - 5.2.3 Complex passwords must contain an Alphabetic Character
  - 5.2.4 Complex passwords must contain a Numeric Character
  - 5.2.5 Complex passwords must contain a Special Character
  - 5.2.6 Complex passwords must uppercase and lowercase letters
  - 5.2.7 Password Age
  - 5.2.8 Password History

## Required Changes/Updates

None

## Change Log

- 2022-06-09: Created Initial File
