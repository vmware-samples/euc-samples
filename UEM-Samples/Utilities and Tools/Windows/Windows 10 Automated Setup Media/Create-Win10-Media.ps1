<#	
	.NOTES
	===========================================================================
	 Updated:   	March 16, 2020
	 Created by:   	Brooks Peppin, www.brookspeppin.com, @brookspeppin
	 Organization: 	VMware, Inc.
	 Filename:     	Create-Win10-Media.ps1
	===========================================================================
	.DESCRIPTION
		Creates Windows 10 setup media that automatically installs via autounattend.xml.Supports both UEFI with Secure Boot on and legacy boot modes.
	.CHANGELOG
		3/16/20
			- Added more thorough check for DVD ISO drive letter in case multiple drives mounted and/or one is inactive

		
#>
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	# Relaunch as an elevated process:
	Start-Process powershell.exe "-File", ('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
	exit
}


Write-Host "================================================================================="
Write-Host "======================= Windows 10 x64 USB Media Creator ========================"
Write-Host "===================== By Brooks Peppin (bpeppin@vmware.com) ====================="
Write-Host "========================== www.brookspeppin.com ================================="
Write-Host "===========================Updated March, 16 2020=================================="
Write-Host "================================================================================="`n
Write-Host "This script creates a bootable Windows 10 media usb key that installs
Windows 10 automatically via an autounattend.xml file. It supports booting with 
either UEFI + Secure Boot or legacy boot modes. However, Windows will be formatted 
in UEFI mode and so ensure your BIOS is set to boot accordingly. It will create
2 partitions (1 FAT32 and 1 NTFS) in order to support consistent UEFI booting."`n

pause
Write-Host "Scanning for mounted ISO..." -ForegroundColor Yellow
$ISO = (get-volume | Where-Object {$_.DriveType -like "CD-ROM" -and $_.OperationalStatus -eq "OK" -and $_.Size -gt 0})

If ($iso)
{
	$isoletter = $ISO.driveletter + ":"
	$friendlyname = $ISO.FileSystemLabel
	Write-Host "Mounted ISO found."
	Write-Host "Drive letter: $isoletter"
	Write-Host "Friendly Name: $friendlyname "
	Write-Host "Is this correct? (y/n)" -foreground "yellow"
	$confirmation = Read-Host
	if ($confirmation -eq 'y')
	{
		write-host "$isoletter drive confirmed. Continuing..."
	}
	else
	{
		exit
	}
}
else
{
	Write-Host "Mounted ISO not found. Please mount a Windows 10 ISO and then type the drive letter where it is mounted. 
Include '\'. For example: E:\" -ForegroundColor Yellow
	$ISO = Read-Host
	$isoletter = $ISO.driveletter + ":"
	$friendlyname = $ISO.FileSystemLabel
	Write-Host "Drive letter: $isoletter"
	Write-Host "Friendly Name: $friendlyname "
	
}


Write-host "Detecting USB drives..." -ForegroundColor Yellow

Get-Disk | where({ $_.BusType -eq 'USB' }) | select Number, FriendlyName, Model, @{ Name = "TotalSize"; Expression = { "{0:N2}" -f ($_.Size/1GB) } } | out-host #Listing drives that ARE USB
Write-host "Enter the correct drive number of the USB drive to format (enter drive number only). For example: 1" -ForegroundColor Yellow
$drivenumber = Read-Host


While ($drivenumber -eq "0")
{
	Write-Host "You have selected drive 0, which is generally your internal HD. Please select a USB drive." -foreground "red"
	Write-host "Detecting USB drives..."
	Get-Disk | where({ $_.BusType -eq 'USB' }) | select Number, FriendlyName, Model, @{ Name = "TotalSize"; Expression = { "{0:N2}" -f ($_.Size/1GB) } } | out-host #Listing drives that ARE USB
	Write-host "Enter the correct drive number of the USB drive to format (enter drive number only). For example: 1" -ForegroundColor Yellow
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
robocopy $isoletter $USB_Boot /mir /xd sources "system volume information" $recycle.bin /njh /njs
robocopy $isoletter\sources $usb_boot\sources boot.wim /njh /njs
Write-Host "Copying sources directory to USB-Source (NTFS) partition"
robocopy $isoletter\sources $usb_source\sources /mir /njh /njs


Remove-Item $usb_source\sources\ei.cfg -Force -ErrorAction SilentlyContinue
Add-Content -Path $usb_source\sources\ei.cfg -Value "[CHANNEL]" -Force
Add-Content -Path $usb_source\sources\ei.cfg -Value "Retail" -Force

Write-host "Would you like to add the autounattend.xml to the USB to enable zero-touch install? (EFI systems only)" -foreground "yellow"
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
	
	Write-Host "Getting Windows Image information..."
	
	
	$ISO_image = Get-WindowsImage -ImagePath $isoletter\sources\install.wim
	
	if (!($ISO_image.Imageindex[0] -eq "1"))
	{
		Write-Host "Getting Windows Image information again..."
		$ISO_image = Get-WindowsImage -ImagePath $isoletter\sources\install.wim
	}
	$ISO_image
	Write-host "Your image may have more than one index. Enter the index number of the version of Windows you would like to install. 
This will update the autounattend.xml file to automatically apply the correct image index." -ForegroundColor Yellow
	$index = Read-Host
	
	$OS_Name = ($ISO_image | where { $_.ImageIndex -eq "$index" }).ImageName
	
	$xml = New-Object XML
	$xml.Load("$USB_Boot\autounattend.xml")
	$xml.unattend.settings.component.imageinstall.osimage.installfrom.metadata.value = $OS_Name
	Write-Host OS Image Name set to $OS_Name -ForegroundColor Yellow
	$xml.Save("$USB_Boot\autounattend.xml")
}
else
{
	exit
}



pause