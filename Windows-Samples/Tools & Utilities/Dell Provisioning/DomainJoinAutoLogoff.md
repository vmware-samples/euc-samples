# Automatically Log out of Administrator Account when Workspace ONE Staged Enrollment is Complete

## Overview
- **Author**: Brooks Peppin
- **Email**: bpeppin@vmware.com
- **Date Updated**: 6/18/2018
- **Supported Platforms**: Workspace ONE 1811 or newer
- **Tested on**: Windows 10 Pro/Enterprise 1803+

## Purpose
When selecting the "On-Premise Active Directory Join", the system automatically logs into the local administrator account to facilitate Workspace ONE staged enrollment. Today, once staged enrollment is complete the system will land on the administrator desktop and will require a manual reboot/log out. Adding this command will automatically reboot the computer once Workspace ONE staged enrollment is completed, thus eliminating the manual step.

## Steps to Implement
1. In the Workspace ONE console, create a new provisioning package by going to Devices > Lifecycle > Staging > Windows > New.
2. On Configurations page, copy and paste the command specified below into the correction section. It's important you add them to either the "Additional Synchronous Command" section or the "First Logon Command" section

## Commands
### Additional Synchronous Command
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer /v AsyncRunOnce /t REG_DWORD /d 0 /f
### First Logon Command 1
powershell while(-not $completed){if((get-itemproperty -path HKLM:\SOFTWARE\AIRWATCH\EnrollmentStatus -ErrorAction SilentlyContinue).status -eq 'Completed'){$Completed = $true; shutdown /r /t 0}else{start-sleep 3}}
### First Logon Command 2
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer /v AsyncRunOnce /t REG_DWORD /d 1 /f