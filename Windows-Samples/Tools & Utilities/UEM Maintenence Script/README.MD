# Start-UEMMaintenance.ps1

## Overview

* Author: Brooks Peppin, www.brookspeppin.com
* Contributors: Ivan Ivanov, Ivan Kanchev, Stefan Grigorov
* Email: bpeppin@vmware.com
* Date Created: 1/23/2020
* Date Updated: 1/26/2021


## Latest Updates
1.2 - Jan 20, 2021
- Added checking for duplicate users and deleting those duplicates (Get-DuplicateUsers, Delete-DuplicateUsers). It will by default only delete duplicate users that do not have devices enrolled. Users with devices enrolled will need to have those devices
	deleted first before deleting the user account. Additionally, adding a UserFilter.csv parameter to the command line (-UserList <path to csv>) will enable you to target only a subset of users. The format should be:
	Column name: Username, Column data: 1 username per line. Example:
	"Username"
	"asmith"
	"bpeppin"
	"cjohnson"
	NOTE: This works on both directory and basic accounts (you can specify a filter by using -UserType. Valid choices are BasicOnly, DirectoryOnly, Any). If directory accounts are deleted, they may get re-created if you have directory sync setup on certain user groups. 
- Changed device based commands to be consistent with user ones. New ones are:
		'Get-DuplicateDevices', 'Delete-DuplicateDevices', 'Get-StaleDevices', 'Delete-StaleDevices', 'Get-ProblematicDevices', 'Delete-ProblematicDevices'
- Dramatically improved speed of checking for duplicates in large environments


1.1 - Initial version, Jan 2020

## Description
    This script connects to your VMware Workspace ONE UEM environment and can get and delete duplicate devices, stale devices, or problematic devices (devices with invalid serials). It can also get duplicate user accounts. Once you run any of the "get" Actions, it will save the data to a csv files (C:\UEM-Maintenance\$server\$date). If you run it again on the same day, it will search for valid CSV files first before reaching out again to the server. This is to improve speed, allow for editing of CSV, and reduce load on the server. If it does not find a valid csv, it will go ahead and reach out to the server. If you need it to get a clean set of data from the server, simply delete the CSV files first. Additionally, it asks for and stores the UEM credentials in an encrypted file (saved C:\UEM-Maintenance\$server\Logs\Creds.txt) with AES encryption. The key is saved C:\UEM-Maintenance\$server\Logs\AES.key. This allows the script to be run in an automated fashion by a service account or  multiple users on the same internal server. However since the key is on the same system, care must be taken on who can access the system this script is running from. Ensure it is secure! This script make no guarantee with the accesibility of the cached creds. This key can also be saved on a different location for improved security.  Recommend deleting stored creds after use if you aren't planning on using this script all the time. Each environment saves credentials separately.

## Requirements
1. REST API Enabled at the OG you wish to target
2. WS1 UEM Administrator account with device read/delete permissions. 

## Instructions

 For full, detailed instructions please see https://brookspeppin.com/2020/01/28/how-to-keep-your-workspace-one-uem-environment-clean/
 
## PARAMETERS
-Server
    Mandatory parameter for the WS1 UEM Server (omit https://). 

-Action
	Mandatory parameter that specifies the action the script should take. Options are: 'Get-Duplicates', 'Delete-Duplicates', 'Get-Stale', 'Delete-Stale', 'Get-Problematic', 'Delete-Problematic'. 

-Apikey
	Mandatory parameter for the API key that is requred for the script to connect via REST API to your server. These keys are per OG and are found under All Settings > System > Advanced > API > REST API.

-Days
	Optional parameter that specifies how many days back the script should check for stale device records. Default is 90 days.  

-FilterSerial
	Optional parameter that filters out serials that are improperly formatted or not yet populated. See the $SerialFilter variable below for the full list. Use this for duplicates only and not stale or problematic.

-UserType
	Optional parameter that filters against certain user types (basic, directory, or any). This only works when alongside 'Get-DuplicateUsers' or 'Delete-DuplicateUsers' function. Valid options are: 'BasicOnly', 'DirectoryOnly', 'Any'.

-UserList
	Optional parameter that will only search for duplicate users or based on a csv file (-UserList <path to csv>). The format of the csv should be:
	Column name: Username, Column data: 1 username per line. Example:
	"Username"
	"asmith"
	"bpeppin"
	"cjohnson"

-Platform
	Optional parameter that specifies which platform type you'd like to search duplicates for. Valid options are: 'Mac', 'Win10', 'Android', 'iOS', 'ChromeOS', 'Any'. Any is the default if no parameter is specified. 
 

## OUTPUTS
  Outputs to host as well as to a log file stored in C:\UEM-Maintenance\$server\Logs\Win_UEM_Maintenence.log. This log is also formatted in a way for cmtrace.exe log viewer to read and process. Each "Get" function also creates csv files under C:\UEM-Maintenance\[server]\Win_[today's date]
  
  ## EXAMPLES
  
.EXAMPLE - Get Duplicate Devices, Filtering Serials
.\Start-UEMMaintenance.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg=" -Action Get-DuplicateDevices -FilterSerial

.EXAMPLE - Get Duplicate Devices, Win10
.\Start-UEMMaintenance.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg=" -Action Get-DuplicateDevices -Platform Win10

.EXAMPLE - Get Stale devices (default of 90 days)
.\Start-UEMMaintenance.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg=" -Action Get-StaleDevices

.EXAMPLE - Get Stale devices older than 120 days
.\Start-UEMMaintenance.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg=" -Action Get-StaleDevices -Days 120

.EXAMPLE - Get problematic devices
.\Start-UEMMaintenance.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg=" -Action Get-ProblematicDevices

.EXAMPLE - Get DuplicateUsers
.\Start-UEMMaintenance.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg=" -Action Get-DuplicateUsers

.EXAMPLE - Get DuplicateUsers, filtering against a csv, and only looking for basic users
.\Start-UEMMaintenance.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg=" -Action Get-DuplicateUsers -UserList C:\temp\userlist.csv -UserType 'BasicOnly'

.EXAMPLE - Delete DuplicateUsers (this will use the "to be deleted csv" from your previous "Get-duplicateusers" command)
.\Start-UEMMaintenance.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg=" -Action Delete-DuplicateUsers

.Example - Delete Duplicate Devices
.\Start-UEMMaintenance.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg="  -Action Delete-DuplicateDevices -FilterSerial

.Example - Delete Stale Devices
.\Start-UEMMaintenance.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg="  -Action Delete-StaleDevices

.Example - Delete Problematic Devices
.\Start-UEMMaintenance.ps1 -server myserver.awmdm.com -ApiKey "zwhD99G6593LDO0D93A030139nZti0sur0Gg="  -Action Delete-ProblematicDevices