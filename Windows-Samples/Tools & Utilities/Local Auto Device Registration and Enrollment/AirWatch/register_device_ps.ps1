#############################################
# File: register_device_ps.ps1
# Author: Chase Bradley
# Description: The following PowerScript file performs 2 functions
#   (1) It registers a device record in AirWatch
#   (2) It enrolls the Windows 10 machine
#############################################

#Test to see if we are running from the script or if we are running from the ISE
if($PSScriptRoot -eq ""){
    #PSScriptRoot only popuates if the script is being run.  Default to default location if empty
    $current_path = "C:\Installs\AirWatch\";
}
else{
    #Only works if running from the file
    $current_path = $PSScriptRoot;
}

#Validation that the file exists on the local drive.  
#Recommendation is to setup the file in the image, but can be downloaded on the fly.
$agentMSI = $current_path + "\AirWatchAgent.msi";
$tempMSI = $current_path + "\setupfiles\AirWatchAgent.msi";
$agentPS = $current_path + "\setupfiles\download_latest_agent.ps1";
if(Test-Path $agentMSI){
    echo "AirWatch Agent Exists"
} else {
    #Download the latest agent
    PowerShell.exe -ExecutionPolicy Bypass -File $agentPS; 
    Move-Item $tempMSI $agentMSI;
}

#Import some utility functions
$utility =  $current_path + "\includes\utility_functions.psm1";
$module = Import-Module $utility -ErrorAction Stop -PassThru -Force;

#Import C# file
cd $current_path;
$RegistrationModule = $current_path + '\Registration.cs'; 

$CompilerParameters = New-Object -TypeName System.CodeDom.Compiler.CompilerParameters;
$dllPath = $current_path + '\bin\System.Web.Helpers.dll'
$CompilerParameters.CompilerOptions = '/reference:System.dll /reference:Microsoft.CSharp.dll' +
    ' /reference:System.Core.dll /reference:WebHelpers=' + $dllPath ;
if (-not ([System.Management.Automation.PSTypeName]'LocalDevice').Type)
{
Add-Type -Path $RegistrationModule -ErrorAction Stop -CompilerParameters $CompilerParameters;
}

#Creates the new Csharp object
$Register = New-Object LocalDevice.Registration;
$Register.initialize($current_path + "\");

#Process the settings
$iniSettings = Get-IniContent($current_path + "\localdevice.ini");

$allowedStagingUsers = "";
#Get potential staging users
if($iniSettings["Staging"]["AllowedStagingUsers"]){
    $allowedStagingUsers = $iniSettings["Staging"]["AllowedStagingUsers"].Split(",");
}

#Get current logged in user && computer name
$user = Get-WmiObject -Class Win32_ComputerSystem | select username
$username = $user.username
#######################################
# Testing credential 
if($iniSettings.ContainsKey("Debug")){
    if($iniSettings["Debug"]["EnableDebug"] -eq 1){
        $username = $iniSettings["Debug"]["DebugUser"];
    }
}
#
#######################################

$computer = Get-WmiObject -Class Win32_ComputerSystem | select Name
$computername = $computer.name
if($allowedStagingUsers -ne ""){
    foreach ($stagingUser in $allowedStagingUsers) 
    {
        $sanitized_user = $username.Replace($computername,'.')
        if($stagingUser -eq $sanitized_user){
            echo "User is staging user. Exiting.";
            return;
        }
    }
}

#Get serial number from WMIC
$serialnumber = wmic bios get serialnumber
$serialARR = $serialnumber[2]

#Sanitize extremely long Serial Numbers (any over 50 get truncated)
if($serialARR.Length -gt 50){
    $serialARR = $serialARR.Substring(0,50);
}
$serialARR = $serialARR.Trim();

#Get AirWatch information from the INI file
$server = $iniSettings["Config"]["Enrollment_Server"];
$groupId = $iniSettings["Config"]["GroupID"];
$stagingUsername = $iniSettings["Config"]["StagingUser"];
$stagingPassword = $iniSettings["Config"]["StagingPassword"];

$regArgs
$regArgs = @{Username=$username;SerialNumber=$serialARR;CreateUser=1};

$isRegister = $Register.RegisterDeviceArg($regArgs);

#only enroll machine if registered
If($isRegister -eq "True"){
    $logLocation = $current_path + "\msi.log";
	msiexec.exe /i AirwatchAgent.msi /quiet ENROLL=Y IMAGE=N SERVER=$server LGName=$groupId USERNAME=$stagingUsername PASSWORD=$stagingPassword /L*V C:\Installs\AirWatch\msi.log
	schtasks /Change /TN "\AirWatch MDM\Enrollment\AirWatch_Registration" /DISABLE
} Else {
	Write-Host "Do not enroll device and email IT"
    if($iniSettings["SMTP"]["UseSMTP"] -eq 1){
        $smtpServer = $iniSettings["SMTP"]["SMTPServer"];
        $recipient = $iniSettings["Config"]["AdminEmailAddress"];
        $sender = $iniSettings["SMTP"]["Sender"];
        $subject = "Failed to enroll $username. The registration script will run on next login!";
        Send-MailMessage -SmtpServer 'smtp.glgroup.com' -from $sender -to $recipient -Subject $subject
    }
}