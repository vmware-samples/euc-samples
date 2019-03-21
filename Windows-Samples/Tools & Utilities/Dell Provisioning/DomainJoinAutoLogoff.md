# Automatically Log out of Administrator Account when Workspace ONE Staged Enrollment is Complete

## Overview
- **Author**: Brooks Peppin
- **Email**: bpeppin@vmware.com
- **Date Created**: 3/21/2018
- **Supported Platforms**: Workspace ONE 1811 or newer
- **Tested on**: Windows 10 Pro/Enterprise 1803+

## Purpose
When selecting the "On-Premisis Active Directory Join", the system automatically logs into the local administrator account to facilitate Workspace ONE staged enrollment. Today, once staged enrollment is complete the system will land on the administrator desktop and will require a manual reboot/log out. Adding this command will automatically reboot the computer once Workspace ONE staged enrollment is completed, thus eliminating the manual step.

## Steps to Implement
1. In the Workspace ONE console, create a new provisioning package by going to Devices > Lifecycle > Staging > Windows > New.
2. On Configurations page, copy and paste the command specified below into the "First Logon Commands" section.
3. Complete the wizard and ensure the command is formatted properly. If any of the special characters don't render properly, simply manually edit the XML file to correct. 

## Command
powershell while(-not $completed){if((get-itemproperty -path HKLM:\SOFTWARE\AIRWATCH\EnrollmentStatus).status -eq 'Completed'){$Completed = $true; shutdown /r /t 0}else{start-sleep 3}}