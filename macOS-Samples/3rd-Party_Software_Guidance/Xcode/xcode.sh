##Script to Configure/Setup xCode for Initial Run without needing Admin Credentials
##Stores Local User as a Variable
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
##Adds Local User to Developer Group
sudo dscl . append  /Groups/_developer GroupMembership $loggedInUser
##Accepts EULA
sudo /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild --license accept
## Performs Initial Component Install
sudo /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -runFirstLaunch
