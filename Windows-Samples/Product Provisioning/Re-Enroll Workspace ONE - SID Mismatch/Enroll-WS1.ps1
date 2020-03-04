<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019
	 Created by:   	bpeppin | www.brookspeppin.com 
	 Organization: 	VMware, Inc.
	 Filename:     	Enroll-WS1.ps1
	===========================================================================
	.DESCRIPTION
		Workspace ONE Enrollment script. 

    .USAGE
		64bit - powershell -executionpolicy bypass -file .\Enroll-WS1.ps1 -server ws1uem.awmdm.com -lgname prod -upn staging@staging.com -password 11111
		32bit - %WINDIR%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file .\Enroll-ws1.ps1 -server ws1uem.awmdm.com -lgname prod -upn staging@staging.com -password 11111

        Full Command line options for airwatchagent.msi: https://docs.vmware.com/en/VMware-AirWatch/9.3/vmware-airwatch-guides-93/GUID-AW93-Enroll_SilentCommands.html
		Complete Onboarding Windows 10 devices using CLI guide: https://techzone.vmware.com/onboarding-windows-10-using-command-line-enrollment-vmware-workspace-one-operational-tutorial
	.NOTES
	v2.1 - Mar 3, 2020
		- Fixed issue with renaming old log files
		- Added additional logging info when enrolling via HUB
	v2 - Feb 28, 2020
		- Added additional waits after Hub un-enrollment and oma-dma sync to ensure everything is cleaned out properly.
		
#>
param (
	[String][Parameter(Mandatory = $true)]
	$server,
	[String][Parameter(Mandatory = $true)]
	$LGName,
	[String][Parameter(Mandatory = $true)]
	$UPN,
	[String][Parameter(Mandatory = $true)]
	$Password
	
)

#------------------------------------------------------------------------
#Variable Section
$version = 'v2'
$scriptfilename = "WS1-Enroll-$env:computername-$version.log" #local log file name
$Logpath = "C:\ProgramData\Airwatch\UnifiedAgent\Logs"
$logfile = "$logpath\$scriptfilename"
$AgentPath = "$PSScriptRoot\AirwatchAgent.msi"
$msiargumentlist = "/i $AgentPath /quiet ENROLL=Y SERVER=$Server LGNAME=$LGName USERNAME=$UPN PASSWORD=$Password ASSIGNTOLOGGEDINUSER=Y /log $Logpath\Awagent.log"
$serial = (gwmi win32_BIOS).SerialNumber
$PATH = "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*"
$val = (Get-ItemProperty -Path $PATH -ErrorAction SilentlyContinue).PSChildname
$path2 = "HKLM:\SOFTWARE\Microsoft\Enrollments\$val"
$global:val2 = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).UPN
#End of Variable Section
#------------------------------------------------------------------------
#functions
Function Write-Log
{
	Param (
		[Parameter(Mandatory = $true)]
		[string]$Message
		
	)
	
	$date = $date = (Get-Date).ToString("dd-M-yyy hh:ss")
	"$date | $Message" | Out-File -Append $LogFile
	Write-Host $Message
}

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	# Relaunch as an elevated process:
	Write-Log "Script is not run with elevated permissions. Please re-run elevated."
	Pause
	exit
}


#Ensuring log locations exist
If ((Test-Path $Logpath) -eq $false)
{
	md $Logpath -ErrorAction SilentlyContinue
}

Function Uninstall-Hub
{
	
	
	write-log "Checking for existing Airwatch/Workspace One Hub installations"
	$uninstallString = @()
	$uninstallString += (Get-ItemProperty HKLM:\Software\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\* | where-Object { $_.DisplayName -like "Airwatch*" -or $_.DisplayName -like "Workspace ONE Intelligent Hub*" }).PSChildName
	$uninstallString += (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where-Object { $_.DisplayName -like "Airwatch*" -or $_.DisplayName -like "Workspace ONE Intelligent Hub*" }).PSChildName
	
	foreach ($string in $uninstallString)
	{
		Try
		{		
			write-log "$string GUID found, uninstalling."
			start-process -Wait "msiexec" -arg "/X $string /qn"

		}
		catch
		{
			write-log $_.Exception
		}
		
	}
	
	Write-Log "Renaming log folder to $Logpath.old"
	Rename-Item $Logpath "$Logpath.old"
	#Ensuring log locations exist
	If ((Test-Path $Logpath) -eq $false)
	{
		md $Logpath -ErrorAction SilentlyContinue
	}
	
	#syncing oma-dm to ensure that it breaks mdm relationship after hub removal
	$GUID = (Get-Item -Path "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*" -ErrorAction SilentlyContinue).PSChildname
	Start-Process "$ENV:windir\system32\DeviceEnroller.exe" -arg "/o $GUID /c"
	write-log "Wait 5 min for OMA-DM Unenrollment to complete"
	sleep 300
	
}

Function Enroll-Hub
{
	
	write-log "Enrolling Workspace ONE Hub with the following parameters: Server= $server, Organization Group ID= $LGName, Staging Username: $UPN, Staging Password: ******, AssignToLoggedInUser=Y"
	Start-Process msiexec.exe -Wait -ArgumentList $msiargumentlist
	write-log "Waiting 5 min for WS1 enrollment to complete the process..."
	start-sleep 300
}



function Enrollment-check
{
	#Compliance Script
	#Checking first for Airwatch Enrollment
	$val = (Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*" -ErrorAction SilentlyContinue).PSChildname

	foreach ($row in $val)
	{
		
		$path2 = "HKLM:\SOFTWARE\Microsoft\Enrollments\$row"
		$upn = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).UPN
		$EnrollmentState = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).EnrollmentState
		#Now checking whether enrollment is true and with a real user or the staging user
	
		if ($upn -eq $null -or $EnrollmentState -eq $null -or $EnrollmentState -eq "0" -or $EnrollmentState -eq "4")
		{
			return $false
		}
		elseif ($upn -like "*staging*")
		{
			return $false
		}
		else
		{
			return $upn
			
		}	
	}
}

function Check-SID
{

	
	
	Write-Log "Checking Windows and enrollment SIDs..."

	New-PSDrive HKU Registry HKEY_USERS -ErrorAction SilentlyContinue | out-null
	$SID = (get-childitem HKU: -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*S-1-12-1*" -or $_.Name -like "*S-1-5-21*" -And $_.Name -notlike "*_classes" }).Name
	Remove-PSDrive HKU
	If ($SID)
	{
		$SID = $SID.Split('\')[1]
		Write-Log "Windows SID=$SID"
	}
	else
	{
		Write-Log "No logged in User to verify SID exiting."
		exit 1
	}

	$GUID = (Get-Item -Path "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*" -ErrorAction SilentlyContinue).PSChildname
	if ($GUID -eq $null)
	{
		Write-Log "No valid enrollment MDM detected"
		return $false
	}
	Else
	{
		foreach ($row in $GUID)
		{
			$path2 = "HKLM:\SOFTWARE\Microsoft\Enrollments\$row"
			$upn = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).UPN
			$enrollmentState = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).EnrollmentState
			$providerID = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).ProviderID
			
			if ($providerID -eq "AirWatchMDM") #Ensure MDM enrollment belongs to WS1
			{
				[string]$EnrollmentSID = (Get-ChildItem HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$row | Where-Object { $_.Name -notlike "*device" }).PSChildName
				Write-Log "Enrollment SID=$EnrollmentSID"
				If ($SID -eq $EnrollmentSID -and $enrollmentState -eq 1)
				{
					Write-Log "SIDs Match"
					Return $true
				}
				else
				{
					Write-Log "SIDs don't match"
					Return $false
				}
			}
			else
			{
			}
		}
	}
}

function check-agent-path
{
	if (!(Test-Path $AgentPath))
	{
		Write-Log "Unable to find AirwatchAgent.msi file in expected location. Downloading latest from the internet."
		#Invoke-WebRequest "https://awagent.com/Home/DownloadWinPcAgentApplication" -outfile "$AgentPath" #this download 19.8 agent
		Invoke-WebRequest "https://storage.googleapis.com/getwsone-com-prod/downloads/AirwatchAgent.msi" -outfile "$AgentPath" #downloads latest production hub installer. Note this may be a newer version than the customer environment.
	}
	else
	{
	Write-Log "Verified AirwatchAgent.msi file"	
	}
	
}

#main Function calls
write-log "Script version is: $version"
Write-Log "Airwatch Agent path: $AgentPath"
$Arch = (Get-Process -Id $PID).StartInfo.EnvironmentVariables["PROCESSOR_ARCHITECTURE"];
if ($Arch -eq 'x86')
{
	Write-log 'Running 32-bit PowerShell, please re-run in 64 bit powershell context.'
	exit 1
}
elseif ($Arch -eq 'amd64')
{
	Write-log 'Running 64-bit PowerShell'
}
check-agent-path
$enrollmentcheck = Enrollment-check
$checkSID = Check-SID
If ($enrollmentcheck -and $checkSID)
{
	write-log "WS1 enrollment Successful. Enrolled as $enrollmentcheck, Serial = $serial"
}
else
{
	write-log "Non-Compliant Enrollment, enrolled as $enrollmentcheck, Serial = $serial"
	check-agent-path
	Uninstall-Hub
	Enroll-Hub
	$enrollmentcheck = Enrollment-check
	If ($enrollmentcheck)
	{
		write-log "Workspace One enrollment Successful. Enrolled as $enrollmentcheck, Serial = $serial"
		
	}
	Else
	{
		write-log "Workspace One enrollment failed. Manual remediation may be required. Enrolled as $enrollmentcheck, Serial = $serial"
		Exit 1
	}
}
