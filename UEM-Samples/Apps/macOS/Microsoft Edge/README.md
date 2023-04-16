# Microsoft Edge Browser for macOS

## Overview

- **Authors**: Robert Terakedis
- **Email**: rterakedis@vmware.com
- **Date Created**: 2020-01-25
- **Tested on macOS Versions**: macOS Catalina 10.15.2

## Purpose

Manage Microsoft Edge Preferences/Settings via Workspace ONE:

1) Download the Install package from Microsoft (link below in [Resources](#Additional-Resources))
2) Create a Custom Settings profile payload that contains any settings you wish to manage (link below in [Resources](#Additional-Resources))
3) Deploy the Microsoft Edge browser app in order to leverage the policies configured in the preferences (via Custom XML)

## Notes Regarding VMware Identity Manager Cert-based Authentication

To manage the Certicficate Picker, use the **AutoSelectCertificateForUrls** key and set the Pattern URL to the CAS URL of your Identity Manager Instance:

- *.vmwareidentity.com = <https://cas-aws.vmwareidentity.com/>
- *.vmwareidentity.eu = <https://cas-aws.vmwareidentity.eu/>
- *.vidmpreview.com = <https://cas.vidmpreview.com/>

The Issuer needs to be the Issuer of your CA. So if your Issuer is CA is **CN=lab-ad01-CA**, use **lab-ad01-CA**.

## Example Custom Settings XML

```XML
<dict>
  <key>FavoritesBarEnabled</key>
  <false/>
  <key>AudioCaptureAllowed</key>
  <true/>
  <key>AudioCaptureAllowedUrls</key>
  <array>
    <string>https://www.contoso.com/</string>
    <string>https://[*.]contoso.edu/</string>
  </array>
  <key>DefaultCookiesSetting</key>
  <integer>1</integer>
  <key>HomepageLocation</key>
  <string>https://www.contoso.com</string>
  <key>ManagedFavorites</key>
  <array>
    <dict>
      <key>toplevel_name</key>
      <string>My managed favorites folder</string>
    </dict>
    <dict>
      <key>name</key>
      <string>Microsoft</string>
      <key>url</key>
      <string>microsoft.com</string>
    </dict>
    <dict>
      <key>name</key>
      <string>Bing</string>
      <key>url</key>
      <string>bing.com</string>
    </dict>
    <dict>
      <key>children</key>
      <array>
        <dict>
          <key>name</key>
          <string>Microsoft Edge Insiders</string>
          <key>url</key>
          <string>www.microsoftedgeinsider.com</string>
        </dict>
        <dict>
          <key>name</key>
          <string>Microsoft Edge</string>
          <key>url</key>
          <string>www.microsoft.com/windows/microsoft-edge</string>
        </dict>
      </array>
      <key>name</key>
      <string>Microsoft Edge links</string>
    </dict>
  </array>
    <key>AutoSelectCertificateForUrls</key>
    <array>
    <string>{"pattern":"https://cas.vidmpreview.com","filter":{"ISSUER":{"CN":”TMApple"}}}</string>
    </array>
    <key>BuiltInDnsClientEnabled</key>
    <false />
    <key>AuthServerAllowlist</key>
    <string>*.domain.com,domain.com</string>
    <key>AuthNegotiateDelegateAllowlist</key>
    <string>domain.com</string>
    <key>PayloadEnabled</key>
    <true/>
    <key>PayloadDisplayName</key>
    <string>Microsoft Edge Settings</string>
    <key>PayloadIdentifier</key>
    <string>com.microsoft.Edge.A9DA433B-BDDA-4205-9147-5A6FC149B54E</string>
    <key>PayloadType</key>
    <string>com.microsoft.Edge</string>
    <key>PayloadUUID</key>
    <string>A9DA433B-BDDA-4205-9147-5A6FC149B54E</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
</dict>
```

## Required Changes/Updates

None

## Change Log

- 2020/02/19 - Initial Upload

## Additional Resources

- [Configure Microsoft Edge for macOS](https://docs.microsoft.com/en-us/deployedge/configure-microsoft-edge-on-mac)
- [Microsoft Edge Policies](https://docs.microsoft.com/en-us/deployedge/microsoft-edge-policies)
- [Microsoft Edge for Business Downloads](https://www.microsoft.com/en-us/edge/business/download)
