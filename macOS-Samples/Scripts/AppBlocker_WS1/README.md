# AppBlocker WS1 Package

* Author: Paul Evans
* Email: pevans@vmware.com
* Originally based off [AppBlocker](https://github.com/erikberglund/AppBlocker) by Erik Berglund
* Date Created: 2/13/2020
* Supported Platforms: WS1 UEM 2001
* Tested on macOS Versions: macOS Catalina


Note: This package is largely based off of the [AppBlocker](https://github.com/erikberglund/AppBlocker) script by Erik Berglund, with some minor updates to handle edge cases and configurations to easily integrate with Workspace ONE.

The included .pkg and .plist files can be uploaded directly to the Workspace ONE Adminsitrator Console, and pre-install and post-uninstall scripts can be configured to easily specify which applications (identified by their Bundle IDs) should not be launched.  If a specified application is launched, the user will receive an alert and the application process will be killed.

![AppBlocker_WS1.png?raw=true](/macOS-Samples/Scripts/AppBlocker_WS1/bin/AppBlocker_WS1.png)

Note: This package is primarily targeted towards end users with Standard user accounts.  Clever users with Administrator account could potentially manipulate or remove this package so it no longer functions as expected.


# Configure pre-install script in WS1

After uploading the included .pkg and .plist files to the Apps & Books section of the Workspace ONE Administrator Console, copy & paste the following script into the pre-install script section of the application configuration.  As needed, modify the "apps=" line to include a comma-separated list of all the Bundle IDs that you would like to block.  Note that punctuation of the Bundle IDs does matter.

```
#!/bin/sh

apps="com.apple.news,com.apple.Music,com.apple.Photos"

mkdir -p /usr/local/bin/ && touch /usr/local/bin/AppBlockerBundles
chown 600 /usr/local/bin/AppBlockerBundles
echo "$apps" > /usr/local/bin/AppBlockerBundles
pid=$(pgrep -f 'Python /usr/local/bin/AppBlocker.py')
if [[ ! -z $pid ]]; then
	kill $pid
fi
```
 
# Configure post-uninstall script in WS1

If the package is removed from devices, the specified apps will continue to be blocked unless the device is rebooted or the Python process is manually stopped.  Alternatively, add the following script to the post-uninstall script section of the application configuration in the Workspace ONE Administrator Console to automatically kill the Python process when the package is removed.

```
#!/bin/sh

pid=$(pgrep -f 'Python /usr/local/bin/AppBlocker.py')
if [[ ! -z $pid ]]; then
	kill $pid
fi
```
