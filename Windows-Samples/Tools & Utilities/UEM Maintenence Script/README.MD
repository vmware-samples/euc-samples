# Start-UEMMaintenance_Windows.ps1

## Overview

* Author: Brooks Peppin, www.brookspeppin.com
* Contributors: Ivan Ivanov, Ivan Kanchev, Stefan Grigorov
* Email: bpeppin@vmware.com
* Date Created: 1/23/2020
* Date Updated: 1/23/2020


## Latest Updates
1.0 - Published to Github

## Description
  This script connects to your VMware Workspace ONE UEM environment and can get and delete duplicates, stale records, or problematic devices (devices with invalid serials). Once you run any of the "get" Actions, it will save the data to a csv files (C:\UEM-Maintenance\$server\Win_$date). If you run it again on the same day, it will search for valid CSV files first before reaching out again to the server. This is to improve speed, allow for editing of CSV, and reduce load on the server. If it does not find a valid csv, it will go ahead and reach out to the server. Additionally, it asks for and stores the UEM credentials in an encrypted file (saved C:\UEM-Maintenance\$server\Logs\Creds.txt) with AES encryption. The key is saved C:\UEM-Maintenance\$server\Logs\AES.key. This allows the script to be run in an automated fashion by a service account or multiple users on the same internal server. However since the key is on the same system, care must be taken on who can access the system this script is running from. Ensure it is secure. This key can also be saved on a different location for improved security.

## Requirements
1. REST API Enabled at the OG you wish to target
2. WS1 UEM Administrator account with device read/delete permissions. 
3. Windows 10 Only (more platforms coming soon...)

## Instructions

**Ensure you are on Windows 10 1803 or newer running this script**
 For full, detailed instructions please see www.brookspeppin.com

.PARAMETER -Server
    Mandatory parameter for the WS1 UEM Server (omit https://). 

.PARAMETER -Action
	Mandatory parameter that specifies the action the script should take. Options are: 'Get-Duplicates', 'Delete-Duplicates', 'Get-Stale', 'Delete-Stale', 'Get-Problematic', 'Delete-Problematic'. 

.PARAMETER -Apikey
	Mandatory parameter for the API key that is requred for the script to connect via REST API to your server. These keys are per OG and are found under All Settings > System > Advanced > API > REST API.

.PARAMETER -Days
	Optional parameter that specifies how many days back the script should check for stale records. Default is 90 days.  

.PARAMETER -FilterSerial
	Optional parameter that filters out serials that are improperly formatted or not yet populated. See the $SerialFilter variable below for the full list. Use this for duplicates only and not stale or problematic.

.OUTPUTS
  Outputs to host as well as to a log file stored in C:\UEM-Maintenance\$server\Logs\Win_UEM_Maintenence.log. This log is also formatted in a way for cmtrace.exe log viewer to read and process. Each "Get" function also 
  creates csv files under C:\UEM-Maintenance\$server\Win_$date
  
.EXAMPLE - Get Duplicates, Filtering Serials
.\Start-UEMMaintenance_Windows.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg=" -Action Get-Duplicates -FilterSerial

.EXAMPLE - Get Stale devices (default of 90 days)
.\Start-UEMMaintenance_Windows.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg=" -Action Get-Stale

.EXAMPLE - Get Stale devices older than 120 days
.\Start-UEMMaintenance_Windows.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg=" -Action Get-Stale -Days 120

.EXAMPLE - Get problematic devices
.\Start-UEMMaintenance_Windows.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg=" -Action Get-Problematic

.Example - Delete Duplicates
.\Start-UEMMaintenance_Windows.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg="  -Action Delete-Duplicates -FilterSerial

.Example - Delete Stale
.\Start-UEMMaintenance_Windows.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg="  -Action Delete-Stale 

.Example - Delete Problematic
.\Start-UEMMaintenance_Windows.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg="  -Action Delete-Problematic