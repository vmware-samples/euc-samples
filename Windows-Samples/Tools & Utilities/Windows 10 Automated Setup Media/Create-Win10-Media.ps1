<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.155
	 Created on:   	1/5/2019 4:09 PM
	 Created by:   	Brooks Peppin, www.brookspeppin.com, bpeppin@vmware.com
	 Organization: 	VMware, Inc.
	 Filename:     	Create-Win10-Media.ps1
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


Write-Host "==================================================================="
Write-Host "================ Windows 10 x64 USB Media Creator ================="
Write-Host "============== By Brooks Peppin (bpeppin@vmware.com) =============="
Write-Host "=================== www.brookspeppin.com =========================="
Write-Host "====================Updated Jul, 29 2019============================"
Write-Host "==================================================================="`n
Write-Host "This script creates a bootable Windows 10 media usb key that installs
Windows 10 automatically via an autounattend.xml file. It supports
both UEFI with Secure Boot on and legacy boot modes. It will create
2 partitions (1 FAT32 and 1 NTFS) in order to support consistent UEFI booting."`n

Write-Host "Please type the drive letter where Windows 10 setup media is mounted.  
Include '\'. For example: E:\" -ForegroundColor Yellow
$ISO = Read-Host
Write-host "Detecting USB drives..."
Get-Disk | where({ $_.BusType -eq 'USB' }) | select Number, FriendlyName, Model, @{ Name = "TotalSize"; Expression = { "{0:N2}" -f ($_.Size/1GB) } } | out-host #Listing drives that ARE USB
Write-host "Please select the correct drive to USB drive to format (enter drive number only)." -ForegroundColor Yellow
$drivenumber = Read-Host


While ($drivenumber -eq "0")
{
	Write-Host "You have selected drive 0, which is generally your internal HD. Please select a USB drive." -foreground "red"
	Write-host "Detecting USB drives..."
	Get-Disk | where({ $_.BusType -eq 'USB' }) | select Number, FriendlyName, Model, @{ Name = "TotalSize"; Expression = { "{0:N2}" -f ($_.Size/1GB) } } | out-host #Listing drives that ARE USB
	Write-host "Please select the correct drive to USB drive to format (enter drive number only). Enter disk number only. For example: 1 " -ForegroundColor Yellow
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
create partition primary size=1000
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


Remove-Item $usb_source\sources\ei.cfg -Force -ErrorAction SilentlyContinue
Add-Content -Path $usb_source\sources\ei.cfg -Value "[CHANNEL]" -Force
Add-Content -Path $usb_source\sources\ei.cfg -Value "Retail" -Force

Write-host "Would you like to add the autounattend.xml to the USB for zero-touch installation? (EFI systems only)" -foreground "yellow"
Write-Host "(y/n)" -foreground "yellow"
$confirmation = Read-Host
if ($confirmation -eq 'y')
{
	Try
	{
		
		Write-Host "Downloading autounattend.xml..."
		Invoke-WebRequest -Uri https://raw.githubusercontent.com/vmware-samples/AirWatch-samples/master/Windows-Samples/Tools%20%26%20Utilities/Windows%2010%20Automated%20Setup%20Media/autounattend.xml -OutFile $USB_Boot\autounattend.xml
	}
	catch
	{
		
		$_.exception
		
	}
	
}
else
{
	exit
}


pause