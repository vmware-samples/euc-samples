# CreateHubLogs - Send device logs to WS1 UEM Admin Console

### Overview
* Author: Paul Evans
* Email: pevans@vmware.com
* Date Created: 8/8/2019
* Supported Platforms: WS1 UEM 1907
* Tested on macOS Versions: macOS Mojave

**Note: As of Workspace ONE UEM 20.05, administrators are able to request Hub Logs from macOS devices directly from the Administrator Console.  In the Device Details page, select More Actions > Request Device Log.  This package is not needed for Workspace ONE 20.05 or later.**

Deploy this pkg to a device through WS1 UEM in order to gather and send relevant WS1 Hub and MDM logs to the WS1 UEM Admin Console.  The logs will be stored in the **Content** section of the Admin Console, stored under a category named **macOS Logs** and under an Organization Group that you specify.  This pkg leverages preinstall and postinstall scripts in order to encrypt API credentials and pass them to the device without saving them locally in plaintext.

**Note:** Access to the Content section of the Admin Console requires WS1 Advanced licenses or greater.

## Preparing your WS1 UEM environment
Before successfully using this script, there are a few items that must be set up in your WS1 UEM environment:

1. Enable the REST API in your environment under Settings > System > Advanced > API > REST API.  Generate an API key with the **Admin** account type.  This API key will be used later.
2. Create an administrator account that you can use as a service account for API calls.  The credentials for this account will be used later.
3. Optional: Create a separate Organization Group used to store all transferred macOS logs.  By default, any logs transferred will have an effective date set in the year 2500, but if you are currently using the Content section for general use, creating a separate Organization Group with no devices enrolled will help keep things organized.  Get the LGID for this group by navigating to Groups & Settings > Groups > Organization Groups > Details, and identifying the number at the end of the URL (1305 in the example image below).

![LGID.png?raw=true](/macOS-Samples/Scripts/CreateHubLogs/bin/LGID.png)

## Setting up the pkg in WS1 UEM

The /build/ folder contains a .pkg and .plist file that you can upload this to the **Apps & Books** section of WS1 UEM.  Otherwise, you can build the payload with a command similar to the following, and then use the VMware Admin Assistant Tool to generate the corresponding .plist:

```bash
pkgbuild --install-location / --identifier "com.vmware.workspaceONE.CreateHubLogs" --version "1.0" --root ./payload/ ./build/CreateHubLogs.pkg
```

When settings up the app in WS1 UEM, navigate to the **Scripts** tab to enter in the following:

#### Pre-Install Script

Paste the following script into the Pre-Install Script section of the app configuration page.  As mentioned in the *Preparing your WS1 UEM Environment* section above, make sure you have the API key, API admin credentials, and LGID number handy to put into the first few lines of the script.  You'll also need to specify the full URL for your WS1 UEM API server (which is typically the same URL as your Admin Console in most environments).

Additionally, specify a password to use for encrypting these values when sent to the device.  As defined in the script, the values will be combined and then encrypted through openSSL, using des3 encryption.  The encrypted file will be temporarily saved on the device, and removed after the API calls are complete.

```bash
#!/bin/bash
url='https://ws1uem.company.com'
user='APIAdminUser'
pass='APIAdminPassword'
LGID='1305'
apikey='APIKeyValue'
encpass='testpassword'

creds=`echo -n "$user:$pass" | base64`
myInfo="$creds|$LGID|$apikey|$url"

mkdir -p "/tmp/Workspace ONE/CreateHubLogs"

echo "$myInfo" | openssl des3 -salt -out "/tmp/Workspace ONE/CreateHubLogs/tempinfo" -pass pass:"$encpass"
```

#### Post-Install Script

Paste the following script into the Post-Install Script section of the app configuration page.  Make sure to enter in the **exact same** encryption password as you did in the preinstall script above.  This will decrypt the values on the device for use in the API calls, without saving the plaintext values locally on the device.

```bash
#!/bin/bash
encpass='testpassword'

info=$(openssl des3 -d -salt -in "/tmp/Workspace ONE/CreateHubLogs/tempinfo" -pass pass:"$encpass")
./tmp/Workspace\ ONE/CreateHubLogs/CreateHubLogs.sh "$info"
```

## Using the CreateHubLogs pkg

When the CreateHubLogs pkg is deployed and installed on a device through WS1 UEM, it will create a zip file of relevant logs from that device and upload them to the Content section of the Admin Console.  If you would like to gather additional logs from the same device at a later time, you must fully **remove** the pkg from the device (and wait for the Console to show it as removed), and then reinstall again.  You can download the log bundle from the Admin Console by selecting the checkbox to the left of it, then the Download option that appears.

![Download.png?raw=true](/macOS-Samples/Scripts/CreateHubLogs/bin/Download.png)
