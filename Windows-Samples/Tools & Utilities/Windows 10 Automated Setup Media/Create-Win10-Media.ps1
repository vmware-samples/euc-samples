<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.155
	 Created on:   	1/5/2019 4:09 PM
	 Created by:   	Brooks Peppin, www.brookspeppin.com
	 Organization: 	
	 Filename:     	Create-Win10-Media
	===========================================================================
	.DESCRIPTION
		Creates Windows 10 setup media that automatically installs via autounattend.xml.Supports both UEFI with Secure Boot on and legacy boot modes.
#>
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	# Relaunch as an elevated process:
	Start-Process powershell.exe "-File", ('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
	exit
}
<## Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
{
	# We are running "as Administrator" - so change the title and background color to indicate this
	$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
	#$Host.UI.RawUI.BackgroundColor = "DarkBlue"
	clear-host
}
else
{
	# We are not running "as Administrator" - so relaunch as administrator
	
	# Create a new process object that starts PowerShell
	$newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
	
	# Specify the current script path and name as a parameter
	$Script = $myInvocation.MyCommand.Definition
	Write-Host $script
	Start-Process powershell -ArgumentList '-noprofile -file $script' -verb RunAs

	# Indicate that the process should be elevated
	#$newProcess.Verb = "runas";
	
	# Start the new process
	#[System.Diagnostics.Process]::Start($newProcess);
 pause
	# Exit from the current, unelevated, process
	exit
}#>


	#Start-Transcript -Path "$env:TEMP\Win10SetupMedia.log" -IncludeInvocationHeader


Write-Host "==================================================================="
Write-Host "================ Windows 10 x64 USB Media Creator ================="
Write-Host "============== By Brooks Peppin (bpeppin@vmware.com) =============="
Write-Host "=================== www.brookspeppin.com =========================="
Write-Host "==================================================================="
Write-Host "This script creates automated Windows 10 setup media that installs "
Write-Host "via autounattend.xml. It supports both UEFI with Secure Boot on"
Write-Host "and legacy boot modes. It will create 2 partitions (1 FAT32 and 1 NTFS)"
Write-Host "in order to support consistent UEFI booting."`n

Write-Host "Please type the drive letter where Windows 10 setup media is mounted. "
Write-Host "Include '\' For example: E:\"
$ISO = Read-Host
Write-host "Detecting USB drives..."
Get-Disk | where({ $_.BusType -eq 'USB' }) | select Number, FriendlyName, Model, @{ Name = "TotalSize"; Expression = { "{0:N2}" -f ($_.Size/1GB) } } | out-host #Listing drives that ARE USB
Write-host "Please select the correct drive to USB drive to format (enter drive number only)."
$drivenumber = Read-Host


	While ($drivenumber -eq "0")
	{
		Write-Host "You have selected drive 0, which is generally your internal HD. Please select a USB drive." -foreground "red"
		Write-host "Detecting USB drives..."
		Get-Disk | where({ $_.BusType -eq 'USB' }) | select Number, FriendlyName, Model, @{ Name = "TotalSize"; Expression = { "{0:N2}" -f ($_.Size/1GB) } } | out-host #Listing drives that ARE USB
	Write-host "Please select the correct drive to USB drive to format (enter drive number only). Enter disk number only. For example: 1 "
		$drivenumber = Read-Host
		
	}
Write-host "You have selected the following drive to format."
Write-Host  "Please ensure this is correct as the drive will be completely formatted! " -ForegroundColor Red
	Get-Disk $drivenumber | select Number, FriendlyName, Model, @{ Name = "TotalSize"; Expression = { "{0:N2}" -f ($_.Size/1GB) } } | out-host
	Write-Host "Is this correct? (y/n)" -foreground "yellow"
	$confirmation = Read-Host
	if ($confirmation -eq 'y')
	{
		write-host "Drive $drivenumber confirmed. Continuing..."
	}
	else
	{
		exit
	}
	
	$command = @"
select disk $drivenumber
clean
convert mbr
create partition primary size=500
create partition primary
select partition 1
online volume
format fs=fat32 quick label=USB-Boot
assign 
active
select partition 2
format fs=ntfs quick label=USB-Source
assign  
exit
"@
	$command | Diskpart
	
	$USB_Boot = ((Get-Volume).where({ $_.FileSystemLabel -eq "USB-Boot" })).DriveLetter + ":"
	$usb_source = ((Get-Volume).where({ $_.FileSystemLabel -eq "USB-Source" })).DriveLetter + ":"
	
	Write-Host "Copying boot files to USB-Boot (Fat32) partition"
	robocopy $iso $USB_Boot /mir /xd sources "system volume information" $recycle.bin /njh /njs
	robocopy $iso\sources $usb_boot\sources boot.wim /njh /njs
	Write-Host "Copying sources directory to USB-Source (NTFS) partition"
	robocopy $iso\sources $usb_source\sources /mir /njh /njs
	
	Add-Content -Path $usb_source\sources\ei.cfg -Value "[CHANNEL]"
	Add-Content -Path $usb_source\sources\ei.cfg -Value "Retail"

	
