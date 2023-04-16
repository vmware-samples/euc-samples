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
<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019
	 Created by:   	bpeppin, Ivan Kanchev, Stefan Grigorov
     Updated:		bpeppinMay-20-2019 | www.brookspeppin.com
	 Organization: 	VMware, Inc.
	 Filename:     	Re-Enroll-WS1.ps1.ps1
	===========================================================================
	.DESCRIPTION
		Workspace ONE Repair and Re-enroll script. This script checks for a valid enrollment and if that fails, does a WMI check and repair, uninstalls Workspace ONE hub,
		as well as triggering SCCM policies as baseline. It also uses the ASSIGNTOLOGGEDINUSER=Y command line parameter which falls back to prompt for username and password if the assigntologgedinuser fails. 
		At a minimum, update this item in the variable section to reflect your unique values, if applicable:
			- $Baselinename

    .USAGE
		If deploying as an SCCM Application:
			powershell -executionpolicy bypass -file Re-enroll-ws1.ps1 -Server company.awmdm.com -LGName Prod -UPN staging@prod.com -Password 11111
		If deployment as an SCCM Package
			%WINDIR%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file .\Re-enroll-ws1.ps1 -Server company.awmdm.com -LGName Prod -UPN staging@prod.com -Password 11111
        Full Command line options for airwatchagent.msi: https://docs.vmware.com/en/VMware-AirWatch/9.3/vmware-airwatch-guides-93/GUID-AW93-Enroll_SilentCommands.html
		Complete Onboarding Windows 10 devices using CLI guide: https://techzone.vmware.com/onboarding-windows-10-using-command-line-enrollment-vmware-workspace-one-operational-tutorial

#>

#------------------------------------------------------------------------
#Variable Section
$version = 'v1'
$scriptfilename = "$env:computername-$version.log" #local log file name
$OwnershipType = "CD" #corporate dedicated.  Select 'CD' for Corporate Dedicated. Select 'CS' for Corporate Shared. Select 'EO' for Employee Owned. Select 'N' for None.
$Logpath = "C:\ProgramData\Airwatch\UnifiedAgent\Logs"
$logfile = "$logpath\Re-Enroll-WS1.log"
$msiargumentlist = "/i $PSScriptRoot\AirwatchAgent.msi /quiet ENROLL=Y SERVER=$Server LGNAME=$LGName USERNAME=$UPN PASSWORD=$Password DEVICEOWNERSHIPTYPE=CD ASSIGNTOLOGGEDINUSER=Y /log $Logpath\Awagent.log"
$BaselineName = "WS1 Enrollment Baseline"
$serial = (gwmi win32_BIOS).SerialNumber
$PATH = "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*"
$val = (Get-ItemProperty -Path $PATH -ErrorAction SilentlyContinue).PSChildname
$path2 = "HKLM:\SOFTWARE\Microsoft\Enrollments\$val"
$global:val2 = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).UPN
#End of Variable Section
#------------------------------------------------------------------------




#Ensuring log locations exist
If ((Test-Path $Logpath) -eq $false)
{
	md $Logpath -ErrorAction SilentlyContinue
}

#functions
Function Write-Log
{
	Param (
		[Parameter(Mandatory = $true)]
		[string]$Message
		
	)
	
	$date = $date = (Get-Date).ToString("dd-M-yyy hh:ss")
	"$date | $Message" | Out-File -Append $LogFile
}

Function Restart-Hub
{
	# Stop Airwatch service "Recover" response
	
	cmd /c  sc.exe failure Airwatchservice reset=86400 actions=//
	
	# Disable Airwatch service
	
	cmd /c taskkill /im TaskScheduler.exe /f
	
	Start-Sleep 10
	
	# Enable Airwatch Service Recovery actions
	
	sc.exe failure AirWatchService reset=86400 actions=restart/1
	
	# Start Airwatch Service
	
	net start AirwatchService
	
}

Function Do-WMIRepair()
{
	$Error.Clear()
	
	"Working on $strComputer"
	$val = Get-ItemProperty -Path "hklm:\SOFTWARE\Microsoft\Wbem\CIMOM" | select -ExpandProperty "Autorecover MOFs"
	Set-ItemProperty -Path "hklm:\SOFTWARE\Microsoft\Wbem\CIMOM" -Name "Autorecover MOFs" -Value ""
	
	#StopWinmgmt
	Set-Service Winmgmt -StartupType Disabled -ErrorAction SilentlyContinue
	If (! $?)
	{
		Write-Log -Message "ERROR: Could not disable Winmgmt"
		$Error.clear
	}
	Else { Write-Log -Message "SUCCESS: Disabled Winmgmt" - }
	Stop-Service Winmgmt -Force -ErrorAction SilentlyContinue
	If (! $?)
	{
		Write-Log -Message "ERROR: Could not Stop Winmgmt"
		$Error.clear
	}
	Else { Write-Log -Message "SUCCESS: Stopped Winmgmt" - }
	
	#Sleep 10 for WMI Startup
	Write-Log -Message "INFO   : Sleeping 10 Seconds for WMI Shutdown"
	Sleep -Seconds 10
	
	#Rename The Repository
	#NO, THIS IS NOT A BEST PRACTICE.  But I have yet to break anything with it so it's how I do
	#If I start breaking stuff, I'll fix it then
	# Step 1, check to see if there is an old backup repository.  Remove it.
	If (Test-Path C:\Windows\System32\wbem\repository.old -ErrorAction SilentlyContinue)
	{
		Remove-Item -Path C:\Windows\System32\wbem\repository.old -Recurse -Force -ErrorAction SilentlyContinue
		If (! $?)
		{
			Write-Log -Message "ERROR: Could not delete the old repository backup, check permissions"
			$Error.clear
		}
		Else
		{
			Write-Log -Message "SUCCESS: Removed the old repository back." -
			Write-Log -Message "    NOTE: You've done this before, there may be deeper system issues"
		}
	}
	
	# Step 2, rename existing repository directory.
	Rename-Item -Path C:\Windows\System32\wbem\repository -NewName 'Repository.old' -Force -ErrorAction SilentlyContinue
	If (! $?)
	{
		Write-Log -Message "ERROR: Could not rename the existing repository, check permissions"
		$Error.clear
	}
	Else { Write-Log -Message "SUCCESS: SUCCESS: Renamed Repository" }
	#Start WMI back up
	Set-Service Winmgmt -StartupType Automatic -ErrorAction SilentlyContinue
	If (! $?)
	{
		Write-Log -Message "ERROR: Could not configure WINMGMT, you're screwed"
		$Error.clear
	}
	Else { Write-Log -Message "SUCCESS: SUCCESS: Configured WINMGMT" }
	Start-Service Winmgmt -ErrorAction SilentlyContinue
	If (! $?)
	{
		Write-Log -Message "ERROR: Could not start WINMGMT, you're screwed"
		$Error.clear
	}
	Else { Write-Log -Message "SUCCESS: SUCCESS: Started WINMGMT" }
	
	#Sleep 10 for WMI Startup
	Write-Log -Message "Sleeping 10 Seconds for WMI Startup"
	Sleep -Seconds 10
	#Start other services that WMI typically takes down with it
	Start-Service iphlpsvc -ErrorAction SilentlyContinue
	If (! $?)
	{
		Write-Log -Message "ERROR: Could not start IP Helper, might not be needed in this environment"
		$Error.clear
	}
	Else { Write-Log -Message "SUCCESS: SUCCESS: Started IP Helper" }
	
	Start-Service Winmgmt -ErrorAction SilentlyContinue
	If (! $?)
	{
		Write-Log -Message "ERROR: Could not configure Security Center, might not be needed in this environment"
		$Error.clear
	}
	Else { Write-Log -Message "SUCCESS: SUCCESS: Started Security Center" }
	
	#Sleep 1 Minute to allow the WMI Repository to Rebuild
	Write-Log -Message "INFO   : Sleep 1 Minute to allow the WMI Repository to Rebuild"
	Sleep -Seconds 60
	
	Write-Log -Message "INFO   : Re-registering DLLs and Mofcomping files, this will take several minutes"
	regsvr32 /s %systemroot%\system32\scecli.dll
	regsvr32 /s %systemroot%\system32\userenv.dll
	Set-Location -Path 'c:\windows\system32\wbem'
	mofcomp cimwin32.mof >> $LogFile
	mofcomp cimwin32.mfl >> $LogFile
	mofcomp rsop.mof >> $LogFile
	mofcomp rsop.mfl >> $LogFile
	# First we do the 32-bit, making sure not to uninstall wmi classes by using -exclude *uninstall*
	Set-Location -Path 'c:\windows\system32\wbem'
	Get-ChildItem -Path .\*.dll -Recurse | ForEach-Object { regsvr32 /s $_.FullName }
	Get-ChildItem -Path .\*.mof -recurse -exclude "*uninstall*.mof" | ForEach-Object { mofcomp $_.FullName >> $LogFile }
	Get-ChildItem -Path .\*.mof -recurse -exclude "*uninstall*.mfl" | ForEach-Object { mofcomp $_.FullName >> $LogFile }
	# Move on to 64-bit, making sure not to uninstall wmi classes by using -exclude *uninstall*
	Set-Location -Path 'C:\Windows\SysWOW64\wbem'
	Get-ChildItem -Path .\*.dll -Recurse | ForEach-Object { regsvr32 /s $_.FullName }
	Get-ChildItem -Path .\*.mof -recurse -exclude "*uninstall*.mof" | ForEach-Object { mofcomp $_.FullName >> $LogFile }
	Get-ChildItem -Path .\*.mof -recurse -exclude "*uninstall*.mfl" | ForEach-Object { mofcomp $_.FullName >> $LogFile }
	#Based on previous troubleshooting this also needs to be mofcomped. Beats reinstalling it...
	Set-Location -Path 'C:\Program Files\Microsoft Policy Platform'
	mofcomp ExtendedStatus.mof >> $LogFile
	mofcomp.exe c:\windows\system32\wbem\win32_encryptablevolume.mof
	
	# Start Windows Management Instrumentation service
	Write-Verbose -Message "Starting Windows Management Instrumentation service"
	Start-Service -Name "Winmgmt"
	Sleep -Seconds 30
	Write-Log -Message "Checking if WMI has recovered on $env:COMPUTERNAME"
	
	#Run a small test against WMI to verify if it now responding.
	try
	{
		Get-WmiObject -ClassName Win32_ComputerSystem -ComputerName $computer -ErrorAction Stop
		Write-Log -Message "$env:COMPUTERNAME, WMI is OK now "
		
	}
	
	catch
	{
		$errordata = @"
Computer = $computer
Exception = $($error[0].Exception)
ErrorId = $($error[0].FullyQualifiedErrorId)
"@
		if ($errordata -like '*invalid class*')
		{
			Write-Log -Message "$env:COMPUTERNAME, WMI is still broken "
		}
		
	}
	Write-Log -Message "Closing WMI check log on $env:COMPUTERNAME"
	
	Write-Log -Message "WMI repair finished. Please continue with SCCM install"
}

Function WMICheck
{
	Write-Log -Message "Doing a basic WMI check."
	try
	{
		Get-WmiObject -ClassName Win32_ComputerSystem -ComputerName $env:COMPUTERNAME -ErrorAction Stop
		Write-Log -Message "WMI seems ok."
	}
	catch
	{
		$errordata = @"
Computer = $computer
Exception = $($error[0].Exception)
ErrorId = $($error[0].FullyQualifiedErrorId)
"@
		if ($errordata -like '*invalid class*')
		{
			Write-Log -Message "$env:COMPUTERNAME, WMI is broken. Starting repair procedure.. "
			Do-WMIRepair
		}
	}
}

Function SCCMAgentPolicy
{
	#Machine Policy Retrieval Cycle
	write-log "Triggering Machine Policy Retrieval Cycle"
	Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"
	#Machine Policy Evaluation Cycle
	write-log "Triggering Machine Policy Evaluation Cycle"
	Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}"
	#Hardware Inventory Cycle
	write-log "Triggering Hardware Inventory Cycle"
	Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}"
	#Software Inventory Cycle
	write-log "Triggering Software Inventory Cycle"
	Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000002}"
}

Function Uninstall-Hub
{
	
	
	write-log "Checking for existing Airwatch Agent installation"
	$uninstallString64_Old = (Get-ItemProperty HKLM:\Software\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\* | where-Object { $_.DisplayName -like "Airwatch*" }).PSChildName
	$uninstallString64 = (Get-ItemProperty HKLM:\Software\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\* | where-Object { $_.DisplayName -like "Workspace ONE Intelligent Hub*" }).PSChildName
	$uninstallString32_Old = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where-Object { $_.DisplayName -like "Airwatch*" }).PSChildName
	$uninstallString32 = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where-Object { $_.DisplayName -like "Workspace ONE Intelligent Hub*" }).PSChildName
	IF ($uninstallString64)
	{
		try
		{
			write-log "$uninstallString64 GUID found"
			write-log "Uninstalling 64bit AirwatchAgent..."
			start-process -Wait "msiexec" -arg "/X $uninstallString64 /qn"
			write-log "Uninstallation completed successfully for 64bit AirwatchAgent..."
			Remove-Item -Path $PATH2 -Force -Recurse -ErrorAction SilentlyContinue
			write-log "Waiting 1 min for MDM unenrollment to complete..."
			start-sleep 60
		}
		catch
		{
			write-log $_.Exception
			write-log "Issues with uninstalling 64bit airwatch agent"
		}
		
	}
	IF ($uninstallString32)
	{
		try
		{
			write-log "$uninstallString32 GUID found"
			write-log "Uninstalling 32bit AirwatchAgent..."
			start-process -Wait "msiexec" -arg "/X $uninstallString32 /qn"
			write-log "UnInstallation completed successfully for 32bit AirwatchAgent..."
			Remove-Item -Path $PATH2 -Force -Recurse -ErrorAction SilentlyContinue
			write-log "Waiting 1 min for MDM unenrollment to complete..."
			start-sleep 60
		}
		catch
		{
			write-log $_.Exception
			write-log "Issues with uninstalling 64bit airwatch agent"
		}
		
	}
	IF ($uninstallString64_old)
	{
		try
		{
			write-log "$uninstallString64_old GUID found"
			write-log "Uninstalling 64bit AirwatchAgent..."
			start-process -Wait "msiexec" -arg "/X $uninstallString64_old /qn"
			write-log "UnInstallation completed successfully for 64bit AirwatchAgent..."
			Remove-Item -Path $PATH2 -Force -Recurse -ErrorAction SilentlyContinue
			write-log "Waiting 1 min for MDM unenrollment to complete..."
			start-sleep 60
		}
		catch
		{
			write-log $_.Exception
			write-log "Issues with uninstalling 64bit airwatch agent"
		}
		
	}
	IF ($uninstallString32_old)
	{
		try
		{
			write-log "$uninstallString32_old GUID found"
			write-log "Uninstalling 32bit AirwatchAgent..."
			start-process -Wait "msiexec" -arg "/X $uninstallString32_old /qn"
			write-log "UnInstallation completed successfully for 32bit AirwatchAgent..."
			Remove-Item -Path $PATH2 -Force -Recurse -ErrorAction SilentlyContinue
			write-log "Waiting 1 min for MDM unenrollment to complete..."
			start-sleep 60
		}
		catch
		{
			write-log $_.Exception
			write-log "Issues with uninstalling 64bit airwatch agent"
		}
		
	}
}

Function Enroll-Hub
{
	
	write-log "Enrolling Workspace ONE Hub..."
	
	Try
	{
		
		Start-Process msiexec.exe -Wait -ArgumentList $msiargumentlist
		write-log "Enrolling Workspace ONE Hub installation completed successfully..."
		write-log "Waiting 2 min for WS1 enrollment to complete the process..."
		start-sleep 120
	}
	catch
	{
		write-log $_.Exception
	}
}

function Invoke-BaselineEval
{
	param (
		[String][Parameter(Mandatory = $true, Position = 1)]
		$ComputerName,
		[String][Parameter(Mandatory = $False, Position = 2)]
		$BLName
	)
	If ($BLName -eq $Null)
	{
		$Baselines = Get-WmiObject -ComputerName $ComputerName -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration
	}
	Else
	{
		$Baselines = Get-WmiObject -ComputerName $ComputerName -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration | Where-Object { $_.DisplayName -like $BLName }
	}
	
	$Baselines | % {
		
		([wmiclass]"\\$ComputerName\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version)
		write-log "SCCM Baseline Reevaluation triggered"
		
	}
	
	
}

function Enrollment-check
{
	#Compliance Script
	#Checking first for Airwatch Enrollment
	$val = (Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*" -ErrorAction SilentlyContinue).PSChildname
	
	#Now checking whether enrollment is with a real user or the staging user
	$path2 = "HKLM:\SOFTWARE\Microsoft\Enrollments\$val"
	$val2 = (Get-ItemProperty -Path $PATH2 -ErrorAction SilentlyContinue).UPN
	
	#This will be "Completed" if it is staged enrollment has completed but not yet flipped to final user
	$staging = (get-itemproperty -path HKLM:\SOFTWARE\AIRWATCH\EnrollmentStatus -ErrorAction SilentlyContinue).status
	$reassignment = (get-itemproperty -path HKLM:\SOFTWARE\AIRWATCH\Reassignment -ErrorAction SilentlyContinue).status
	
	
	if ($staging -eq "Completed" -and $reassignment -eq $null)
	{
		return $false
	}
	Elseif ($val2 -like "*staging*" -or $val2 -eq $null)
	{
		return $false
	}
	else
	{
		return $true
	}
	
	
}

#main Function calls
write-log "Script version is: $version"

If (Enrollment-Check)
{
	write-log "Airwatch enrollment Successful. Enrolled as $global:val2, Serial = $serial"
}
else
{
	write-log "Non-Compliant Enrollment, enrolled as $global:val2, Serial = $serial"
	WMICheck
	Uninstall-Hub
	Enroll-Hub
	SCCMAgentPolicy
	Invoke-BaselineEval -ComputerName $env:COMPUTERNAME -BLName $BaselineName
	If (Enrollment-Check)
	{
		write-log "Workspace One enrollment Successful. Enrolled as $global:val2, Serial = $serial"
		
	}
	Else
	{
		write-log "Workspace One enrollment failed. Manual remediation may be required. Enrolled as $global:val2, Serial = $serial"
		Exit 1
	}
}






