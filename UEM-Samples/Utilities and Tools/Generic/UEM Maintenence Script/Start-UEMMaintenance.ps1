<#
.SYNOPSIS
  This script connects to your VMware Workspace ONE UEM environment and can get and delete duplicate devices, stale devices, or problematic devices (devices with invalid serials). It can also get duplicate user accounts. Once you run any of the "get" Actions,
  it will save the data to a csv files (C:\UEM-Maintenance\$server\$date). If you run it again on the same day, it will search for valid CSV files first before reaching out again to the server. This is to improve speed, allow for editing of CSV, and
  reduce load on the server. If it does not find a valid csv, it will go ahead and reach out to the server. If you need it to get a clean set of data from the server, simply delete the CSV files first. Additionally, it asks for and stores the UEM credentials in an encrypted file 
  (saved C:\UEM-Maintenance\$server\Logs\Creds.txt) with AES encryption. The key is saved C:\UEM-Maintenance\$server\Logs\AES.key. This allows the script to be run in an automated fashion by a service account or  multiple users on the same internal server.
  However since the key is on the same system, care must be taken on who can access the system this script is running from. Ensure it is secure! This script make no guarantee with the accesibility of the cached creds. This key can also be saved on a different location for improved security.
  Recommend deleting stored creds after use if you aren't planning on using this script all the time. Each environment saves credentials separately. 

.NOTES
  Version:       	 		1.2
  Author:        		 	Brooks Peppin, www.brookspeppin.com
  Blog: 					https://brookspeppin.com/2020/01/28/how-to-keep-your-workspace-one-uem-environment-clean-uem-maintenance-script-for-windows-10/
  Initial Creation Date: 	Jan 14, 2021

.CHANGELOG
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

.PARAMETER -Server
    Mandatory parameter for the WS1 UEM Server (omit https://). 

.PARAMETER -Action
	Mandatory parameter that specifies the action the script should take. Options are: 'Get-Duplicates', 'Delete-Duplicates', 'Get-Stale', 'Delete-Stale', 'Get-Problematic', 'Delete-Problematic'. 

.PARAMETER -Apikey
	Mandatory parameter for the API key that is requred for the script to connect via REST API to your server. These keys are per OG and are found under All Settings > System > Advanced > API > REST API.

.PARAMETER -Days
	Optional parameter that specifies how many days back the script should check for stale device records. Default is 90 days.  

.PARAMETER -FilterSerial
	Optional parameter that filters out serials that are improperly formatted or not yet populated. See the $SerialFilter variable below for the full list. Use this for duplicates only and not stale or problematic.

.PARAMETER -UserType
	Optional parameter that filters against certain user types (basic, directory, or any). This only works when alongside 'Get-DuplicateUsers' or 'Delete-DuplicateUsers' function. Valid options are: 'BasicOnly', 'DirectoryOnly', 'Any'.

.PARAMETER -UserList
	Optional parameter that will only search for duplicate users or based on a csv file (-UserList <path to csv>). The format of the csv should be:
	Column name: Username, Column data: 1 username per line. Example:
	"Username"
	"asmith"
	"bpeppin"
	"cjohnson"

.PARAMETER -Platform
	Optional parameter that specifies which platform type you'd like to search duplicates for. Valid options are: 'Mac', 'Win10', 'Android', 'iOS', 'ChromeOS', 'Any'. Any is the default if no parameter is specified. 


.OUTPUTS
  Outputs to host as well as to a log file stored in C:\UEM-Maintenance\$server\Logs\Win_UEM_Maintenence.log. This log is also formatted in a way for cmtrace.exe log viewer to read and process. Each "Get" function also 
  creates csv files under C:\UEM-Maintenance\$server\Win_$date
  
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


#>

param (
	[parameter(Mandatory = $true)]
	[string]$server,
	[string]$ApiKey,
	[int32]$days = 90,
	[switch]$FilterSerial = $false,
	[parameter(Mandatory = $true)]
	[ValidateSet('Get-DuplicateDevices', 'Delete-DuplicateDevices', 'Get-StaleDevices', 'Delete-StaleDevices', 'Get-ProblematicDevices', 'Delete-ProblematicDevices', 'Get-DuplicateUsers', 'Delete-DuplicateUsers')]
	[string]$Action,
	[ValidateSet('Mac', 'iOS', 'Win10', 'Android', 'ChromeOS', 'Any')]
	$platform,
	[ValidateSet('Any', 'BasicOnly', 'DirectoryOnly')]
	$UserType,
	[ValidateScript( {
			if (-Not ($_ | Test-Path) ) {
				throw "File or folder does not exist"
			}
			if (-Not ($_ | Test-Path -PathType Leaf) ) {
				throw "The Path argument must be a file. Folder paths are not allowed."
			}
			if ($_ -notmatch "(\.csv)") {
				throw "The file specified in the path argument must be csv"
			}
			return $true 
		})]
	[System.IO.FileInfo]$UserList
)

##################
#Define variables#
##################
$version = "1.2"
$date = ((Get-Date).AddDays(- $days)).ToString('yyyy-MM-dd')
$ExportFileLocation = "C:\UEM-Maintenance\$server\$((Get-Date).ToString('yyyy-MM-dd'))" #using  ISO 8601 format
$LogFilePath = "C:\UEM-Maintenance\$server\Logs\"
$StaleDevice_csv = "StaleDevices.csv"
$AllDevice_csv = "AllDevices.csv"
$allusers_csv = "Allusers.csv"
$DuplicateDevice_csv = "AllDuplicateDevices.csv"
$DuplicateUser_csv = "AllDuplicateUser.csv"
$ProblematicDevice_csv = "ProblematicDevices.csv"
$DoNotDeletedevice_csv = "DoNotDeleteList.csv"
$DoNotDeleteUsers_csv = "DoNotDeleteUsers.csv"
$DuplicateToBeDeleted_csv = "DuplicateDevicesToBeDeleted.csv"
$DuplicateUsersToBeDeleted_csv = "DuplicateUsersToBeDeleted.csv"
#$UserFilter = "UserFilter.csv"
$SerialFilter = @(
	'System Serial Number',
	'To be filled by O.E.M.',
	'Default string',
	'',
	'0',
	'1234567')
$FriendlySerialFilter = foreach ($row in $SerialFilter) {
	
	$row + ","
}
$stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
#######################################################################

function Write-Log {
	
	########################################
	#Write log file with special formating.#
	#The location of the file is hardcoded.#
	########################################
	Param (
		[Parameter(Mandatory = $true)]
		[string]$Message
	)
	
	If ((Test-Path $LogFilePath) -eq $false) {
		md $LogFilePath
	}
	
	$date = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
	$date + '...' + $Message | Out-File -FilePath $LogFilePath\Win_UEM_Maintenence.log -Append
	Write-Host $Message
}

function Create-SecureCredentials {
	Write-Log -Message "Creating secure credentials..."
	try {
		$credential = Get-Credential
		#converting to plain text so we can format it in username:password format that REST API needs
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password)
		$PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
		$credential = $credential.UserName + ":" + $PlainPassword
		#Creating AES key with random data and export to file
		$KeyFile = "$LogFilePath\AES.key"
		$Key = New-Object Byte[] 16 # You can use 16, 24, or 32 for AES
		[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
		$Key | out-file $KeyFile
		#Creating encrypted username/password file with key
		$CredsFile = "$LogFilePath\Creds.txt"
		$KeyFile = "$LogFilePath\AES.key"
		$Key = Get-Content $KeyFile
		$credential | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString -key $Key | Out-File $CredsFile
		Write-Log -Message "Done"
	}
	catch {
		Write-Log -Message $_.Exception
	}

	
}

function Get-SecureCredentials {
	Write-Log -Message "Getting encrypted credentials..."
	If ((Test-Path "$LogFilePath\Creds.txt")) {
		$CredsFile = "$LogFilePath\Creds.txt"
		$KeyFile = "$LogFilePath\AES.key"
		$Key = Get-Content $KeyFile
		$creds = Get-Content $CredsFile | ConvertTo-SecureString -Key $key
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($creds)
		$Authorization = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
		$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Authorization)
		$EncodedText = [Convert]::ToBase64String($Bytes)
		$global:hdrs = @{ "Authorization" = "Basic $EncodedText"; "aw-tenant-code" = "$ApiKey"; "accept" = 'application/json' } 
		$global:hdrs2 = @{ "Authorization" = "Basic $EncodedText"; "aw-tenant-code" = "$ApiKey"; "accept" = 'application/json;version=2' } 
		
	}
	else {
		Write-Log -Message "Encrypted credentials file not found. Prompting for credentials."
		Create-SecureCredentials
		Get-SecureCredentials
	}
	
	
	
}

function Get-StaleDevices {
	
	
	
	################################
	#criteria to filter all devices#
	################################
	
	Write-Log -Message "Looking for existing csv of stale devices..."
	If ((Test-Path $ExportFileLocation\$StaleDevice_csv)) {
		Write-Log -Message "$ExportFileLocation\$StaleDevice_csv found!"
		Write-Log -Message "Importing $StaleDevice_csv"
		$devices = Import-Csv $ExportFileLocation\$StaleDevice_csv
		Write-Log -Message "$(($devices | Measure-Object).Count) devices found."
		$output = $devices
	}
	else {
		Write-Log -Message "No csv of stale devices found. Getting from All Device list..."
		$devices = Get-AllDevices
	}
	
	#########################
	#Export filtered devices#
	#########################
	$output = foreach ($device in $devices) {
		if ($device.LastSeen -eq $null -or $device.LastSeen -eq "0001-01-01") {
			#do nothing
		}
		elseif ($device.LastSeen -le $date) {
			#add to array
			$device
		}
	}
	$output | Export-Csv -Path $ExportFileLocation\$staledevice_csv -NoTypeInformation
	Write-Log -Message "$(@($output.count)) devices have not communicated with UEM since ""$date ($days days)""."
	Write-Log -Message "$(@($output.Count)) stale devices exported to ""$ExportFileLocation\$staledevice_csv""."
	$global:StaleToBeDeleted = $output
	return $output | Out-Null
	
}

function Get-ProblematicDevices {
	
	################################################################
	#1st-Filter all 'problematic' devices base on specific criteria#
	#2nd-Export all 'problematic' filtered devices                 #
	################################################################
	Write-Log -Message "Looking for existing csv of problematic devices..."
	If ((Test-Path $ExportFileLocation\$ProblematicDevice_csv)) {
		Write-Log -Message "$ExportFileLocation\$ProblematicDevice_csv found!"
		Write-Log -Message "Importing $ProblematicDevice_csv"
		$devices = Import-Csv $ExportFileLocation\$ProblematicDevice_csv
		Write-Log -Message "$(($devices | Measure-Object).Count) devices found."
		$output = $devices
	}
	else {
		Write-Log -Message "No csv of problematic devices found. Getting from All Device list..."
		$devices = Get-AllDevices
	}
	
	
	$output = foreach ($device in $devices) {
		#looking for "problematic serials per the Serial Filter"
		if ($SerialFilter -contains $device.SerialNumber) {
			$device
		}
	}
	Write-Log -Message "$(@($output.Count)) devices with problematic serials exported to $ExportFileLocation\$ProblematicDevice_csv"
	$output | Export-Csv $ExportFileLocation\$ProblematicDevice_csv -NoTypeInformation
	$global:ProblematicToBeDeleted = $output
	Return $output | Out-Null
}

function Get-DuplicateDevices {
	

	Write-Log -Message "Looking for existing csv of duplicate devices..."
	If ((Test-Path $ExportFileLocation\$DuplicateDevice_csv)) {
		Write-Log -Message "$ExportFileLocation\$DuplicateDevice_csv found!"
		Write-Log -Message "Importing $DuplicateDevice_csv"
		$devices = Import-Csv $ExportFileLocation\$DuplicateDevice_csv
		Write-Log -Message "$(($devices | Measure-Object).Count) devices found."
		$output = $devices
	}
	else {
		Write-Log -Message "No csv of duplicate devices found. Getting from All Device list..."
		$devices = Get-AllDevices
		If ($FilterSerial) {
			Write-Log -Message "Looking for duplicate devices and filtering out $FriendlySerialFilter"
			$devices = $devices | Where-Object { $_.SerialNumber -NotContains $SerialFilter }

		}

		$dupes = $devices | Group-ObjectCount SerialNumber | Where-Object { $_.count -gt 1 }
		$Count = ($dupes | measure-object).count
		Write-log "There are $count devices with duplicates"

	}
		

	Write-Log -Message "Exporting to $ExportFileLocation\$DuplicateDevice_csv"
	$dupes | Out-file $ExportFileLocation\$DuplicateDevice_csv
		
	

	Write-Log -Message "Sorting and excluding the most recently seen devices from the list..."

	$ToBeDeleted = @()
	$DoNotDeleteList = @()
	foreach ($device in $dupes) {
		#This sorts first by "LastSeen" and then by "DeviceID" so that the latest device is chosen (i.e. most recently seen) in the case where last seen dates are the same
		$DoNotDeleteList += $device.Group | Sort-Object -Property LastSeen, DeviceID -Descending | Select-Object -First 1 
		$ToBeDeleted += $device.Group | Sort-Object -Property LastSeen, DeviceID -Descending | Select-Object -Skip 1 
			
	}
	Write-Log -Message "$(@($DoNotDeleteList).Count) devices that should NOT be deleted and will be excluded (most recently seen devices)."
	$DoNotDeleteList | Export-Csv $ExportFileLocation\$DoNotDeletedevice_csv -NoTypeInformation
	Write-Log -Message "DoNotDelete list exported to $ExportFileLocation\$DoNotDeletedevice_csv"
	
	Write-Log -Message "Duplicates to be deleted final list exported to $ExportFileLocation\$DuplicateToBeDeleted_csv"
	$ToBeDeleted | Export-Csv $ExportFileLocation\$DuplicateToBeDeleted_csv -NoTypeInformation
	$global:DuplicatesToBeDeleted = $ToBeDeleted
	$ToBeDeleted | Out-Null
	
}

function Format-DevicesForDelete {

	Param (
		[Parameter(Mandatory = $true)]
		$InputData
	)
	
	$output = foreach ($row in $InputData) {
		if (($row -eq ($InputData[$InputData.Length - 1]))) {
			$temp = """$($row.DeviceID)"""
		}
		else {
			$temp = """$($row.DeviceID)"","
		}
		$temp
	}
	
	return $output
	
}

function Delete-DevicesFromUEM {
	
	#######################################################################################
	#This function will preform API POST Method to delete all devices marked for deletion.#
	#######################################################################################
	Param (
		[Parameter(Mandatory = $true)]
		$InputData
	)
	
	Write-Log -Message "Start UEM API REST method - POST (Deleting devices)."
	
	try {
		$Body = @"
{
    "BulkValues": {
        "Value":[$($InputData)]
    }
}
"@
		Invoke-RestMethod -Uri "https://$server/api/mdm/devices/bulk" -Method POST -Headers $global:hdrs -ContentType "application/json" -Body $Body
		
	}
	catch {
		$ErrorType = $_.Exception.GetType()
		$ErrorCode = $_.Exception.Response.StatusCode.value__
		$ErrorDescription = $_.Exception.Response.StatusDescrip
		Write-Log -Message "An error occurred: Error Type: $ErrorType, Error Code:$ErrorCode, Error Description:$ErrorDescription"
	}
	Write-Log -Message "Finish UEM API REST method - POST (Deleting devices)."
}

function Delete-DuplicateUsers {
	
	#######################################################################################
	#This function will preform API POST Method to delete all users marked for deletion.  #
	#######################################################################################
	Param (
		[Parameter(Mandatory = $true)]
		$InputData
	)
	
	Write-Log -Message "Starting deleting of users"

	foreach ($row in $InputData) {

		[string]$uuid = $row.uuid
		Invoke-RestMethod -Uri "https://$server/api/system/users/$uuid" -Method DELETE -Headers $global:hdrs2 -ContentType "application/json"
	}
	Write-Log -Message "Finished deleting users."

}

function Create-Folder {
	
	######################################################################################
	#This function will create a new folder every time when UEM maintenance is triggered.#
	#Folder name will be the format 'Win_(Date)'.                                        #
	#All files are going to be saved in this folder.                                     #
	######################################################################################
	Write-Log -Message "Checking if export folder $ExportFileLocation exists."
	
	
	If ((Test-Path $ExportFileLocation) -eq $false) {
		Write-Log "Folder doesn't exist. Creating folder..."
		md $ExportFileLocation
	}
	else {
		Write-Log -Message "Folder $ExportFileLocation exists"
	}
	
}
function Group-ObjectCount {
	#From https://www.pipehow.tech/group-object/
	param
	(
		[string[]]
		$Property,

		[switch]
		$NoElement
	)

	begin {
		# create an empty hashtable
		$hashtable = @{}
	}


	process {
		# create a key based on the submitted properties, and turn
		# it into a string
		$key = $(foreach ($prop in $Property) { $_.$prop }) -join ','
        
		# check to see if the key is present already
		if ($hashtable.ContainsKey($key) -eq $false) {
			# add an empty array list 
			$hashtable[$key] = [Collections.Arraylist]@()
		}

		# add element to appropriate array list:
		$null = $hashtable[$key].Add($_)
	}

	end {
		# for each key in the hashtable, 
		foreach ($key in $hashtable.Keys) {
			if ($NoElement) {
				# return one object with the key name and the number
				# of elements collected by it:
				[PSCustomObject]@{
					Count = $hashtable[$key].Count
					Name  = $key
				}
			}
			else {
				# include the content
				[PSCustomObject]@{
					Count = $hashtable[$key].Count
					Name  = $key
					Group = $hashtable[$key]
				}
			}
		}
	}
}
function Get-DuplicateUsers {
	switch ($UserType) {
		'Any' { 
			$Type = $null
			Write-Log "Usertype filter set to all user types"
		}
		'BasicOnly' {
			$Type = "2"
			Write-Log "Usertype filter set to Basic Only"
		}
		'DirectoryOnly' {
			$Type = "1"
			Write-Log "Usertype filter set to Directory Only"
		}
		Default {}
	}
	Write-Log -Message "Looking for existing csv of duplicate users..."
	If ((Test-Path $ExportFileLocation\$DuplicateUser_csv)) {
		Write-Log -Message "$ExportFileLocation\$DuplicateUser_csv found!"
		Write-Log -Message "Importing $DuplicateUser_csv"
		$users = Import-Csv $ExportFileLocation\$DuplicateUser_csv
		Write-Log -Message "$(($users | Measure-Object).Count) users found."
		$output = $users
	}
	else {
		Write-Log -Message "No existing csv of duplicate users found. Getting from all users list..."
		$users = Get-AllUsers

		Write-Log -Message "Counting duplicates..."
		If ($Type) {
			#If true, then use usertype filter
			$users = $users | Where-Object { $_.Type -eq $type }
		
		}

		$dupes = $users | Group-ObjectCount username | Where-Object { $_.count -gt 1 }

		Write-log "There are $(@(($dupes | measure-object).count)) accounts with duplicates"

		Write-Log -Message "Duplicate users exported to $ExportFileLocation\$DuplicateUser_csv"
		$dupes | out-file $ExportFileLocation\$DuplicateUser_csv
		
	}

	Write-Log -Message "Creating DoNotDelete list of users that have enrolled devices."
	$ToBeDeleted = @()
	$DoNotDeleteList = @()
	foreach ($user in $dupes) {
		for ($i = 0; $i -lt $user.Count; $i++) {
			If ($user.Group[$i].EnrolledDevices -eq "" -or $user.Group[$i].EnrolledDevices -eq 0) {
				$temp = $user.Group[$i] | select username, ID, UUID, EnrolledDevices
				$ToBeDeleted += $temp
			}
			else {
				$DoNotDeleteList += ($user.Group[$i] | select username, ID, UUID, EnrolledDevices)
			}
			
		}

	} 

	Write-Log -Message "$(@($DoNotDeleteList).Count) users excluded since they had enrolled devices."
	$DoNotDeleteList | Out-file $ExportFileLocation\$DoNotDeleteUsers_csv 
	Write-Log -Message "DoNotDelete list exported to $ExportFileLocation\$DoNotDeleteUsers_csv"
	
	Write-Log -Message "$(@($ToBeDeleted).Count) Duplicate Users to-be-deleted. Final list exported to $ExportFileLocation\$DuplicateUsersToBeDeleted_csv"
	$ToBeDeleted | Out-file $ExportFileLocation\$DuplicateUsersToBeDeleted_csv 

	return $ToBeDeleted | out-null
	
}

function Get-AllDevices {
	
	
	If ((Test-Path $ExportFileLocation\$alldevice_csv)) {
		Write-Log -Message "Existing $alldevice_csv file found in $ExportFileLocation\$alldevice_csv. Importing device list from there..."
		$devices = Import-Csv $ExportFileLocation\$alldevice_csv
		Write-Log -Message "Found $(@($devices.count)) devices."
		return $devices
	}
	else {
		Write-Log -Message "No $alldevice_csv file found in $ExportFileLocation\$alldevice_csv, getting all devices from $server..."

		switch ($platform) {
			'Mac' {
				$platform = "platform=AppleOSX"
			}
			'iOS' {
				$platform = "platform=Apple"
			}
			'Win10' {
				$platform = "platform=WinRT"
			}
			'Android' {
				$platform = "platform=Android"
			}
			'Chrome' {
				$platform = "platform=ChromeOS"
			}
			'Any' {
				$platform = ''
			}
		
			Default { $platform = '' }
		}
	
		$i = 0
		$devices = $null
		do {
			Write-Log "Querying page $i"
			$temp = (Invoke-RestMethod -Uri "https://$server/api/mdm/devices/search?$platform&page=$i&pagesize=30000" -Method Get -Headers $global:hdrs -ContentType "application/json").Devices
			$devices += $temp
			$i++
			
		}
		until ($temp -eq $null)
	}
	Write-Log -Message "$(@($devices.count)) total devices were found from UEM via API"
	Write-Log -Message "Formatting data structure..."
	$output = $Null
	$output = foreach ($row in $devices) {
		#formatting data. 
		Try {
	
			$table = @{
				'UDID'               = $row.udid
				'SerialNumber'       = $row.SerialNumber
				'DeviceFriendlyName' = $row.DeviceFriendlyName
				'MACAddress'         = $row.MacAddress
				'EnrollmentStatus'   = $row.EnrollmentStatus
				'LastEnrolled'       = ($row.LastEnrolledOn).Split('T')[0]
				'LastEnrolledTime'   = ($row.LastEnrolledOn).Split('T')[1]
				'LastSeen'           = ($row.LastSeen).Split('T')[0]
				'DeviceID'           = $row.id.Value
				'Model'              = $row.Model
				'UserEmail'          = $row.UserEmailAddress
				'User'               = $row.UserName
			}
			$obj = New-Object -TypeName PSObject -Property $table
			$obj
		}
		catch {

		}
		
	}
	$output | Export-Csv $ExportFileLocation\$alldevice_csv -NoTypeInformation -ErrorAction SilentlyContinue
	Write-Log -Message "$(@($devices.count)) total devices were exported to $ExportFileLocation\$alldevice_csv"
	return $output

}

function Get-AllUsers {
	If ((Test-Path $ExportFileLocation\$allusers_csv)) {
		Write-Log -Message "Existing $allusers_csv file found in $ExportFileLocation\$allusers_csv. Importing user list from there..."
		$users = Import-Csv $ExportFileLocation\$allusers_csv
		Write-Log -Message "Found $(@($users.count)) user(s) in the csv."
		return $users
	}
	else { 
		If ($UserList) {
			Write-Log -Message "User list filter found in path: $UserList. Importing..."
			$userlist = Import-Csv $UserList
			$usercount = ($userlist | measure-object).count
			Write-Log -Message "Found $usercount user(s) in the csv."

		
			Write-Log -Message "Getting user for those $usercount user(s) info from $server..."

			foreach ($row in $userlist) {
				$username = $row.username
				$users += (Invoke-RestMethod -Uri "https://$server/api/system/users/search?username=$username" -Method Get -Headers $global:hdrs -ContentType "application/json").Users

			}
			
		}
		else {
			Write-Log -Message "Getting user info from $server..."
			$i = 0
			do {
				Write-Log "Querying page $i"
				$temp = (Invoke-RestMethod -Uri "https://$server/api/system/users/search?page=$i&pagesize=10000&orderby=username" -Method Get -Headers $global:hdrs -ContentType "application/json").Users
				$users += $temp
				write-log "$(@($users.count)) total users found"
				$i++
			} until ($temp -eq $null)

		}
			
		Write-Log -Message "Formatting data..."
				
		$output = foreach ($row in $users) {
			#formatting data. 
			Try {
				$table = @{
					'FirstName'       = $row.FirstName
					'LastName'        = $row.LastName
					'Username'        = $row.UserName
					'UserEmail'       = $row.Email
					'OGName'          = $row.Group
					'Type'            = $row.SecurityType #1 is directory, 2 is basic
					'Status'          = $row.Status
					'EnrolledDevices' = $row.EnrolledDevicesCount
					'UUID'            = $row.UUID
					'ID'              = $row.ID.value
				}
				$obj = New-Object -TypeName PSObject -Property $table
				$obj
			}
			catch {
				
			}
			
		}
		$output | Export-Csv $ExportFileLocation\$allusers_csv -NoTypeInformation -ErrorAction SilentlyContinue
		Write-Log -Message "$(@($users.count)) total users were exported to $ExportFileLocation\$allusers_csv"
		return $output
	}

	
}

#############################
#	Starting Main Script	#
#############################

Write-Log -Message "Start Log"
$version = "Running script version: 1.2"

Get-SecureCredentials
Create-Folder

switch ($Action) {

	'Get-DuplicateDevices' {
		Get-DuplicateDevices
		
	}
	'Delete-DuplicateDevices' {
		Get-DuplicateDevices
		$deletions = Format-DevicesForDelete -InputData ($global:DuplicatesToBeDeleted)
		Delete-DevicesFromUEM -InputData $deletions
	}
	'Get-StaleDevices' {
		Get-StaleDevices
	}
	'Delete-StaleDevices' {
		Get-StaleDevices
		$deletions = Format-DevicesForDelete -InputData ($global:StaleToBeDeleted)
		Delete-DevicesFromUEM -InputData $deletions
		
	}
	'Get-ProblematicDevices' {
		Get-ProblematicDevices
	}
	'Delete-ProblematicDevices' {
		Get-ProblematicDevices
		$deletions = Format-DevicesForDelete -InputData ($global:ProblematicToBeDeleted)
		Delete-DevicesFromUEM -InputData $deletions
	}
	'Get-DuplicateUsers' {
		Get-DuplicateUsers

	}
	'Delete-DuplicateUsers' {
		$deletions = Get-DuplicateUsers
		Delete-DuplicateUsers -InputData $deletions

	}
}
$stopWatch.Stop()
Write-Log "Script took $(@($stopwatch.Elapsed.Minutes )) minutes and $(@($stopWatch.Elapsed.Seconds)) seconds to run."