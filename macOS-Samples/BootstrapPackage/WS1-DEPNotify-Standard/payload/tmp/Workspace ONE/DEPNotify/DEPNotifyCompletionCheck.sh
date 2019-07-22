CURRSTEP=$(tail -1 /tmp/Workspace\ ONE/DEPNotify/DEPNotifyCurrentStep.txt)
TOTALSTEPS=$(tail -1 /tmp/Workspace\ ONE/DEPNotify/DEPNotifyTotalSteps.txt)
((CURRSTEP++))
echo "$CURRSTEP" > "/tmp/Workspace ONE/DEPNotify/DEPNotifyCurrentStep.txt"

echo $CURRSTEP
echo $TOTALSTEPS

if [ "$CURRSTEP" == "$TOTALSTEPS" ]
then
	echo 'Status: Complete!' >> /private/var/tmp/depnotify.log
	echo 'Command: Quit: Your device is now fully configured!' >> /private/var/tmp/depnotify.log
	rm -rf /Library/LaunchAgents/com.vmware.ws1.depnotify.plist
fi