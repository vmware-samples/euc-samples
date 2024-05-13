# EUC-samples is now hosted https://github.com/euc-oss/euc-samples.
# This repo is no longer maintained.

# dockutil Post-Install Script for MacOS Internal Apps

There are times where it would be useful to add icons to the user's dock after installing a new application.   The following script can be added as a post-install script in order to call an open source utility script (dockutil) to add the item as desired.

## dockutil Post-Install Script

```bash
#!/bin/sh

CurrentUser=`/usr/bin/stat -f%Su /dev/console`

if [ "$CurrentUser" == "root"  ] || [ "$CurrentUser" == "_mbsetupuser" ] ; then
  exit 0
fi

/usr/bin/su -l $CurrentUser -c "/usr/local/bin/dockutil --add /Applications/Intelligent\ Hub.app/"
/usr/bin/su -l $CurrentUser -c "/usr/bin/killall cfprefsd"
/usr/bin/su -l $CurrentUser -c "/usr/bin/killall Dock"

exit 0
```

## Script Explanation

* CurrentUser : This is the user currently logged into macOS
* `/usr/local/bin/dockutil -add` : This is the dockutil utility that modifies the dock plist.
* `/usr/bin/killall cfprefsd` : This command restarts process that reads preferences for the user - this way when the dock restarts it builds from a current set of preferences.
* `/usr/bin/killall Dock` : This command restarts the dock to make the changes immediately visible to the user.


## Additional Resources
* [dockutil by Kyle Crawford](https://github.com/kcrawford/dockutil)
* [Operational Tutorial - Deploying Third-Party macOS Applications](https://techzone.vmware.com/deploying-third-party-macos-applications-vmware-workspace-one-operational-tutorial)
* [VMware Code](https://code.vmware.com/home)
* [VMware Developer Community](https://communities.vmware.com/community/vmtn/developer)
