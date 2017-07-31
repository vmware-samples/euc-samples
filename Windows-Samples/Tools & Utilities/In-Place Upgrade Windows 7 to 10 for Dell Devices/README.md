# In-Place Migration: Windows 7 to Windows 10 for Dell Devices

## Overview
- **Authors**: Jeffrey Handy, Josue Negron
- **Email**: jhandy@vmware.com, jnegron@vmware.com
- **Date Created**: 7/28/2017

## Introduction 
This is a sample project which upgrades the OS from Windows 7 to Windows 10, converts the hard disk from MBR to GPT, switches BIOS from Legacy to UEFI, and lastly installs AirWatch  Agent and performs device onboarding into AirWatch.  
 
This document will provide a step by step of the entire migration process, some key benefits, and will put all the pieces together to show how it works. This code is provided as a sample and can be modified to work with other OEMs, and to perform additional actions. 
 
### Upgrade the OS from Windows 7 to Windows 10 
Windows 10 has many improvements and new add-ins from Windows 7 – Here are just a few: 

- Faster boot time, better hardware acceleration, longer battery life for mobile devices, and mobile device integration. 

- Generally doing a OS upgrade can be a process that requires a CD,DVD, or USB boot drive that it must boot up to, and requires user interaction. 
#### Key Benefits of the In-Place Migration: 
The necessary files needed to do the upgrade are contained within a folder that is copied into the client machine(s). The back-end scripts will do everything for the client – no interaction needed, no CD or USB needed during the install.
### Convert the Hard Disk from MBR to GPT 
The conversion of the hard disk consists of changing the partition structure of the hard disk. Partitions are containers that contain the file system and usable storage space. The hard disk can be split into many partitions. When one is looking at files on their desktop, they are typically located in “C:\users\desktop”. The “C:” tells us what partition it is. 
![](http://i.imgur.com/YOE0fEC.png)
The old partition standard is MBR (Master Boot Record). It was initially introduced in 1983. The newer partition standard is GPT. The primary advantages of GPT are as follows but not limited to:


- Drives setup as GPT can be much larger then MBR
- GPT also allows for a nearly unlimited amount of partitions (MBR four primary partitions)
- It is easier to recover data in a GPT drive
- Windows can only boot from GPT on a UEFI based system

Generally converting from MBR to GPT is a very destructive process requiring the deleting of partitions, which will wipe everything that was contained within it.
#### Key Benefits of the In-Place Migration:
A solution was created internally to convert from MBR to GPT without having to wipe the partitions, and leaving the OS intact. Recently Microsoft has created their own solution that does the same conversion. The two converters are virtually the same, thus the Microsoft GPT converter was integrated into the In-Place Migration project, and if support is needed, you can contact Microsoft directly.
### Switch BIOS from Legacy to UEFI
Switching from Legacy to UEFI is actually required if one wants to use the GPT partition style on their drive. Since UEFI and GPT are tied together, they have similar benefits:


- UEFI does not contain or require a boot-loader like MBR
- Faster boot time
- Mouse capable
- Better hardware compatibility - 32-bit or 64-bit (BIOS 16-bit)
- Secure Boot
- Required for GPT

Typically, to switch the BIOS to UEFI the system needs to be restarted and one has to go into the BIOS and manually change it to UEFI.
#### Key Benefits of the In-Place Migration:
The tool allows the client to change the BIOS to UEFI while logged into windows, and it will automatically take effect after a reboot.
### Install AirWatch Agent and Onboard Devices
Built internally, has multiple functions, and was a necessary process of the migration. The migration will auto enroll the AirWatch Agent per the Administrators discretion. This uses the command line enrollment features of the AirWatch Agent. 
### Putting it all together
Before the migration can begin, the installation files need to be copied to the primary C: drive. If the installation files have been copied, then the migration can begin. The migration itself does not require internet, or network access. The best way to initiate the migration is by running a login script. One can manually setup the login script on the local machine or if an Active Directory environment exists, then create a group policy that runs the script per respective organizational unit. When the migration starts running it will detect if the installation files exist, if so the next step is for it to confirm what kind of platform the system is running “32bit, or 64bit". If the scripts detects that you are running a 64-bit system, it will confirm if you are running Windows 10. If Windows 10 is not detected, it will begin the Windows 10 installation (note – it will upgrade the client to the Windows 10 installation media placed in the Win10 folder). Once the Windows 10 installation completes, it will confirm if the systems is running GPT style partitioning. If it is not on GPT, it will run the following tools:

- MBR 2 GPT Converter
- BIOS to UEFI Application
- Force a Restart
- Install AirWatch Agent

When the tools run successfully it will force a restart, install the AirWatch Agent silently, and the migration is complete. The migration will take a Windows 7 machine running on Legacy BIOS, with an MBR partition style to the latest build of Windows 10 running on UEFI, with GPT partition. If the migration process is implemented in an Active Directory environment, it will automatically upgrade all windows 7, and 8 machines. It will also fix any windows 10 machines that are still setup with MBR partition disk(s). I did not mention it as a primary task, but I have added a script that disables UAC. Disabling UAC should not be a concern as it was not designed as a security feature, but merely used to modify IL (integrity level). I have attached a flowchart of the process to make it easier to visualize below. 

![](http://i.imgur.com/Z5jPQ1w.png)
## Deployment Steps
### Prerequisites

- Must be running at least Windows 7 64-bit 
- Must have at least 4 GB of free space on the primary disk
- The Operating System being migrated must be installed on the C: drive
- The disk where the migration is being installed on can have only one primary partition

***NOTE**: The scripts can be modified if the above prerequisites are not met.*
### Pre-Deployment
Prior to deployment the "*AirwatchAutoenrollment.exe*" needs to be ran to configure how the AirWatch enrollment will install.

![](http://i.imgur.com/0KgR09b.png)

1. Fill in your Device Services (DS) URL e.g. ds###.awmdm.com
2. Enter your Group ID
3. Enter the Staging user's username 
4. Enter the Staging user's password
5. Click Generate AirWatch Script. The previous script will be overwritten (AirWatchAgent.cmd)

> **NOTE**: You will also need to create a "*win10*" folder and extract your Windows 10 ISO to this folder with the proper *setup.exe* file. You also need to update the *install.cmd* file with the product key for activation or push out a profile via AirWatch with the product key for activation. 

### The Deployment
The deployment process is started by running the script “*windows10upgade.bat*”. The deployment cannot start unless the “*Deploymentshare*” folder and everything within it exists on the C: drive. When the “*Deploymentshare*” folder has been copied to the C: drive, the next step is to setup “*windows10upgade.bat*” as a login script as follows:

1. Go to > C:\DeplymentShare\Win10upgrade
2. Right Click “*windows10upgade.bat*” > then click Copy (CTRL+C)
3. Close out explorer window > tap Windows key
4. Type “Edit Group”, in the search window, Edit group policy should popup, click to open it
5. Double click User Configuration > Windows Settings > Scripts (Logon/Logoff) > Logon
6. There will now be two clickable buttons, “Show Files” an “Add”, click Show Files
7. Paste the “*windows10upgade.bat*” script into the new folder that popped up
8. Close the current explorer window, and that will take you back to Logon Properties
9. Click > Add > Browse > the “*windows10upgade.bat*” script should be in there
10. Double click file then > OK > Apply > OK

***NOTE:** You can also deploy the Logon Script via domain Group Policy if the devices are domain-joined.*

Please view below screenshots to view the steps above.

![](http://i.imgur.com/58BbnD4.png)
![](http://i.imgur.com/eSBOokP.png) 
![](http://i.imgur.com/ez7p9Ih.png)
![](http://i.imgur.com/Ie0PYy4.png)
![](http://i.imgur.com/lYMRNod.png)

At this point, the script is ready to start at next login. The steps above should be similar in an AD environment with the exception that the script would be added into the “Group Policy Management Console”, and it would be applied to an AD OU.

## Testing
### Operating Systems Tested On
I ran the migration with success on the following Operating systems:

- Window 7 Home to Windows 10 Enterprise
- Window 7 Professional to Windows 10 Enterprise
- Windows 8 Professional to Windows 10 Enterprise
- Windows 10 Professional to Windows 10 Enterprise

#### Key Note:
If the migration is going from windows 8 to Windows 10 there is a 5 minute delay that occurs when it is ran as a login script, due to a default login delay local policy that affects all windows 8, and Server 2012 systems. It can be modified if Windows 8 migrations are a concern.
### Applications that Migrated Successfully
- Microsoft Office Professional 2010 (No Mailbox)
- Microsoft Office Professional 2013 (No Mailbox)
- Microsoft Office Professional Plus 2016 (Mailbox(s) – Hotmail, and Gmail account)
- Firefox 52.0
- AIM 7.5.21.5
- Spotify 1.0.50.41368
- Audacity 2.1.2
- FastStone Image Viewer 6.2
- Filezilla Client 3.25.0
- Foobar2000 1.3.14
- Revo Uninstaller 2.0.2
- Skype 7.33
- WinDirStat 1.1.2
- Winrar 5.4.0

#### Key Note:
The applications where randomly selected with the exception of the office suites.
### Additional Testing
The migration tool contains an application that converts the hard disk from MBR to GPT. The MBR to GPT works well for most scenarios. 


> **NOTE**: It did not function when I deliberately left random segments of the disk unallocated, specifically the Initial segments, and it will not run if the system that is to be migrated has more than one primary partition on the destination disk. In real case scenarios there would never be segments of the hard disk left unallocated, and the hard disk would not be split to separate primary partitions in an enterprise environment.

These are all of the following machines that were used for testing:

- Dell Latitude E5540
- Dell Latitude E7240
- Dell Latitude E7250
- Dell Latitude E6330


> **NOTE**: The Dell Latitude E5540 had issues with switching the BIOS from Legacy to UEFI. It needed to be changed manually on all occasions even though the script ran correctly, and there was a flash BIOS update.

> **AirWatch Auto Enrollment** – Will not work if there is no internet connection. It will need to be uninstalled if there was no internet connection during the migration. The script will detect if the AirWatch Agent is not installed, and attempt a reinstall.

#### Key Note:
Currently the migration is intended for Dell systems, it may be possible to modify it for other system types. 

## Change Log
- 7/28/2017: Created Sample for Migration from Windows 7 to 10 