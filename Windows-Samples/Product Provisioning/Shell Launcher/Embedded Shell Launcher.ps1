# PowerShell.exe -ExecutionPolicy Bypass -File "C:\Temp\AirWatch\Embedded Shell Launcher.ps1"

# Enable EmbeddedShellLauncher (if the below line works, you will not have to run the enable ESL.bat file, if it doesn't comment this line)
enable-windowsoptionalfeature -online -featureName Client-EmbeddedShellLauncher

$COMPUTER = "localhost"
$NAMESPACE = "root\standardcimv2\embedded"

# Create a handle to the class instance so we can call the static methods.
$ShellLauncherClass = [wmiclass]"\\$COMPUTER\${NAMESPACE}:WESL_UserSetting"


# This well-known security identifier (SID) corresponds to the BUILTIN\Administrators group.

$Admins_SID = "S-1-5-32-544"

# Create a function to retrieve the SID for a user account on a machine.

function Get-UsernameSID($AccountName) {

    $NTUserObject = New-Object System.Security.Principal.NTAccount($AccountName)
    $NTUserSID = $NTUserObject.Translate([System.Security.Principal.SecurityIdentifier])

    return $NTUserSID.Value

}

# Get the SID for a user account named "Kiosk". Rename "Kiosk" to an existing account on your system to test this script.

$Tech_SID = Get-UsernameSID("Kiosk")

# Define actions to take when the shell program exits.

$restart_shell = 0
$restart_device = 1
$shutdown_device = 2

# Examples. You can change these examples to use the program that you want to use as the shell.

# This example sets the command prompt as the default shell, and restarts the device if the command prompt is closed. 

$ShellLauncherClass.SetDefaultShell("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", $restart_shell)

# Display the default shell to verify that it was added correctly.

#$DefaultShellObject = $ShellLauncherClass.GetDefaultShell()

#"`nDefault Shell is set to " + $DefaultShellObject.Shell + " and the default action is set to " + $DefaultShellObject.defaultaction

# Set Internet Explorer as the shell for "Kiosk", and restart the machine if Internet Explorer is closed.

#$ShellLauncherClass.SetCustomShell($Tech_SID, "c:\program files\internet explorer\iexplore.exe www.microsoft.com", ($null), ($null), $restart_shell)

# Set Explorer as the shell for administrators.

$ShellLauncherClass.SetCustomShell($Admins_SID, "explorer.exe")

# View all the custom shells defined.

#"`nCurrent settings for custom shells:"
#Get-WmiObject -namespace $NAMESPACE -computer $COMPUTER -class WESL_UserSetting | Select Sid, Shell, DefaultAction

# Enable Shell Launcher

$ShellLauncherClass.SetEnabled($TRUE)

$IsShellLauncherEnabled = $ShellLauncherClass.IsEnabled()

"`nEnabled is set to " + $IsShellLauncherEnabled.Enabled

# Remove the new custom shells.

#$ShellLauncherClass.RemoveCustomShell($Admins_SID)

#$ShellLauncherClass.RemoveCustomShell($Tech_SID)

# Disable Shell Launcher

#$ShellLauncherClass.SetEnabled($FALSE)

#$IsShellLauncherEnabled = $ShellLauncherClass.IsEnabled()

#"`nEnabled is set to " + $IsShellLauncherEnabled.Enabled