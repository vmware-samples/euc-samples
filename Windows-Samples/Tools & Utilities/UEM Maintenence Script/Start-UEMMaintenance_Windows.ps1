<#
.SYNOPSIS
  This script connects to your VMware Workspace ONE UEM environment and can get and delete duplicates, stale records, or problematic devices (devices with invalid serials). Once you run any of the "get" Actions,
  it will save the data to a csv files (C:\UEM-Maintenance\$server\Win_$date). If you run it again on the same day, it will search for valid CSV files first before reaching out again to the server. This is to improve speed, allow for editing of CSV, and
  reduce load on the server. If it does not find a valid csv, it will go ahead and reach out to the server. Additionally, it asks for and stores the UEM credentials in an encrypted file 
  (saved C:\UEM-Maintenance\$server\Logs\Creds.txt) with AES encryption. The key is saved C:\UEM-Maintenance\$server\Logs\AES.key. This allows the script to be run in an automated fashion by a service account or 
  multiple users on the same internal server. However since the key is on the same system, care must be taken on who can access the system this script is running from. Ensure it is secure. This key can also be saved on
  a different location for improved security.

.NOTES
  Version:        1.0
  Author:         Brooks Peppin, www.brookspeppin.com
  Contributors:   Ivan Kanchev, Ivan Ivanov
  Creation Date:  Jan 23, 2020
  Purpose/Change: Initial script development and publishing on github

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


#>

param (
	[parameter(Mandatory = $true)]
	[string]$server,
	[parameter(Mandatory = $true)]
	[string]$ApiKey,
	[int32]$days = 90,
	[switch]$FilterSerial = $false,
	[parameter(Mandatory = $true)]
	[ValidateSet('Get-Duplicates', 'Delete-Duplicates', 'Get-Stale', 'Delete-Stale', 'Get-Problematic', 'Delete-Problematic')]
	[string]$Action
)

##################
#Define variables#
##################
$date = ((Get-Date).AddDays(- $days)).ToString('yyyy-MM-dd')
$ExportFileLocation = "C:\UEM-Maintenance\$server\Win_$((Get-Date).ToString('yyyy-MM-dd'))" #using  ISO 8601 format
$LogFilePath = "C:\UEM-Maintenance\$server\Logs\"
$StaleDevice_csv = "Win_StaleDevices.csv"
$AllDevice_csv = "Win_AllDevices.csv"
$DuplicateDevice_csv = "Win_AllDuplicateDevices.csv"
$ProblematicDevice_csv = "Win_ProblematicDevices.csv"
$DoNotDeletedevice_csv = "Win_DoNotDeleteList.csv"
$DuplicateToBeDeleted_csv = "Win_DuplicateDevicesToBeDeleted.csv"
$SerialFilter = @(
	'System Serial Number',
	'To be filled by O.E.M.',
	'Default string',
	'',
	'0',
	'1234567')
$FriendlySerialFilter = foreach ($row in $SerialFilter)
{
	
	$row + ","
}
#######################################################################

function Write-Log
{
	
	########################################
	#Write log file with special formating.#
	#The location of the file is hardcoded.#
	########################################
	Param (
		[Parameter(Mandatory = $true)]
		[string]$Message
	)
	
	If ((Test-Path $LogFilePath) -eq $false)
	{
		md $LogFilePath
	}
	
	$date = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
	$date + '...' + $Message | Out-File -FilePath $LogFilePath\Win_UEM_Maintenence.log -Append
	Write-Host $Message
}

function Create-SecureCredentials
{
	Write-Log -Message "Creating secure credentials..."
	try
	{
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
	catch
	{
		Write-Log -Message $_.Exception
	}

	
}

function Get-SecureCredentials
{
	Write-Log -Message "Getting encrypted credentials..."
	If ((Test-Path "$LogFilePath\Creds.txt"))
	{
		$CredsFile = "$LogFilePath\Creds.txt"
		$KeyFile = "$LogFilePath\AES.key"
		$Key = Get-Content $KeyFile
		$creds = Get-Content $CredsFile | ConvertTo-SecureString -Key $key
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($creds)
		$Authorization = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
		$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Authorization)
		$EncodedText = [Convert]::ToBase64String($Bytes)
		$global:hdrs = @{ "Authorization" = "Basic $EncodedText"; "aw-tenant-code" = "$ApiKey"; "accept" = 'application/json' } #uat
		
	}
	else
	{
		Write-Log -Message "Encrypted credentials file not found. Prompting for credentials."
		Create-SecureCredentials
		Get-SecureCredentials
	}
	
	
	
}

function Get-StaleDevices
{
	
	
	
	################################
	#criteria to filter all devices#
	################################
	
	Write-Log -Message "Looking for existing csv of stale devices..."
	If ((Test-Path $ExportFileLocation\$StaleDevice_csv))
	{
		Write-Log -Message "$ExportFileLocation\$StaleDevice_csv found!"
		Write-Log -Message "Importing $StaleDevice_csv"
		$devices = Import-Csv $ExportFileLocation\$StaleDevice_csv
		Write-Log -Message "$(($devices | Measure-Object).Count) devices found."
		$output = $devices
	}
	else
	{
		Write-Log -Message "No csv of stale devices found. Getting from All Device list..."
		$devices = Get-AllDevices
	}
	
	#########################
	#Export filtered devices#
	#########################
	$output = foreach ($device in $devices)
	{
		if ($device.LastSeen -eq $null -or $device.LastSeen -eq "0001-01-01")
		{
			#do nothing
		}
		elseif ($device.LastSeen -le $date)
		{
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

function Get-ProblematicDevices
{
	
	################################################################
	#1st-Filter all 'problematic' devices base on specific criteria#
	#2nd-Export all 'problematic' filtered devices                 #
	################################################################
	Write-Log -Message "Looking for existing csv of problematic devices..."
	If ((Test-Path $ExportFileLocation\$ProblematicDevice_csv))
	{
		Write-Log -Message "$ExportFileLocation\$ProblematicDevice_csv found!"
		Write-Log -Message "Importing $ProblematicDevice_csv"
		$devices = Import-Csv $ExportFileLocation\$ProblematicDevice_csv
		Write-Log -Message "$(($devices | Measure-Object).Count) devices found."
		$output = $devices
	}
	else
	{
		Write-Log -Message "No csv of problematic devices found. Getting from All Device list..."
		$devices = Get-AllDevices
	}
	
	
	$output = foreach ($device in $devices)
	{
		#looking for "problematic serials per the Serial Filter"
		if ($SerialFilter -contains $device.SerialNumber)
		{
			$device
		}
	}
	Write-Log -Message "$(@($output.Count)) devices with problematic serials exported to $ExportFileLocation\$ProblematicDevice_csv"
	$output | Export-Csv $ExportFileLocation\$ProblematicDevice_csv -NoTypeInformation
	$global:ProblematicToBeDeleted = $output
	Return $output | Out-Null
}

function Get-DuplicateDevices
{
	
	##########################################################
	#Creating full duplicate list							 #
	##########################################################
<#	Param (
		[Parameter(Mandatory = $true)]
		$InputData

	)
	#>
	Write-Log -Message "Looking for existing csv of duplicate devices..."
	If ((Test-Path $ExportFileLocation\$DuplicateDevice_csv))
	{
		Write-Log -Message "$ExportFileLocation\$DuplicateDevice_csv found!"
		Write-Log -Message "Importing $DuplicateDevice_csv"
		$devices = Import-Csv $ExportFileLocation\$DuplicateDevice_csv
		Write-Log -Message "$(($devices | Measure-Object).Count) devices found."
		$output = $devices
	}
	else
	{
		Write-Log -Message "No csv of duplicate devices found. Getting from All Device list..."
		$devices = Get-AllDevices
		If ($FilterSerial)
		{
			Write-Log -Message "Looking for duplicate devices and filtering out $FriendlySerialFilter"
			$Names = @{ } #Hash table that will be used to track count of serials
			Write-Log -Message "Building hash table to count number of occurrences of each serial"
			foreach ($row in $devices)
			{
				#Searches each row and increments serial number count if duplicates are found. This also excludes serials we don't want.
				if ($SerialFilter -contains $row.SerialNumber)
				{
					#do nothing
				}
				else
				{
					$Names[$row.SerialNumber] += 1
				}
			}
		}
		else
		{
			Write-Log -Message "Looking for duplicate devices with no serial filter"
			$Names = @{ } #Hash table that will be used to track count of serials
			Write-Log -Message "Building hash table to count number of occurrences of each serial"
			foreach ($row in $devices)
			{
				#Searches each row and increments serial number count if duplicates are found. 
				$Names[$row.SerialNumber] += 1
			}
		}
		
		Write-Log -Message "Building new list of just the duplicates..."
		$duplicates = $names.GetEnumerator() | Where-Object { $_.Value -gt 1 } #array of only serials that have more than one record (duplicates)
		Write-Log -Message "Getting full device info for all duplicates and putting into new list"
		$output = foreach ($device in $devices) #enumerating through all records and comparing serial with the one in the hash table. If true then serial is duplicate and we want to get the full object details of each. 
		{
			if ($duplicates.name -contains $device.SerialNumber)
			{
				#$device | Export-Csv $ExportFileLocation\$DuplicateDevice_csv -NoTypeInformation -Append #makes csv of all records that have duplicate (or more than duplicate) serials
				$device
			}
		}
		Write-Log -Message "$(@($output.Count)) total duplicate devices were found. Exporting to $ExportFileLocation\$DuplicateDevice_csv"
		$output | Export-Csv $ExportFileLocation\$DuplicateDevice_csv -NoTypeInformation
		
	}
	
	
	
	
	#################################################
	#Creating Do Not Delete List					#
	#################################################
	
	Write-Log -Message "Sorting and excluding the most recently seen devices from the list..."
	$DoNotDeleteList = $output | Group-Object -Property 'SerialNumber' | ForEach-Object{ $_.Group | Sort-Object -Property LastSeen, DeviceID -Descending | Select-Object -First 1 } #This sorts first by "LastSeen" and then by "DeviceID" so that the latest device is chosen in the case where last seen dates are the same
	Write-Log -Message "$(@($DoNotDeleteList).Count) devices that should NOT be deleted and will be excluded (most recently seen devices)."
	$DoNotDeleteList | Export-Csv $ExportFileLocation\$DoNotDeletedevice_csv -NoTypeInformation
	Write-Log -Message "DoNotDelete list exported to $ExportFileLocation\$DoNotDeletedevice_csv"
	
	###########################################################
	#Extracting all duplicate devices after have been filtered#
	###########################################################
	Write-Log -Message "Assembling final list of duplicate devices to be deleted..."
	$ToBeDeleted = foreach ($row in $output)
	{
		#if DeviceID is found in "Do not delete" list (i.e. the most recent device that is seen in console), then don't add to list. Else add to list which will be queue for deletion.
		#This is essentially "TotalDuplicates - DoNotDelete"
		if ($DoNotDeleteList.DeviceID -contains $row.deviceID)
		{
			#skip
		}
		else
		{
			$row
		}
	}
	
	Write-Log -Message "Duplicates to be deleted final list exported to $ExportFileLocation\$DuplicateToBeDeleted_csv"
	$ToBeDeleted | Export-Csv $ExportFileLocation\$DuplicateToBeDeleted_csv -NoTypeInformation
	$global:DuplicatesToBeDeleted = $ToBeDeleted
	$ToBeDeleted | Out-Null
	
}

function Format-DevicesForDelete
{
	#########################################################################################################
	#This function will format all device udid's in a specific format to meet the UEM REST API requirements.#
	#########################################################################################################
	Param (
		[Parameter(Mandatory = $true)]
		$InputData
	)
	
	$output = foreach ($row in $InputData)
	{
		if (($row -eq ($InputData[$InputData.Length - 1])))
		{
			$temp = """$($row.DeviceID)"""
		}
		else
		{
			$temp = """$($row.DeviceID)"","
		}
		$temp
	}
	
	return $output
	
}

function Delete-DevicesFromUEM
{
	
	#######################################################################################
	#This function will preform API POST Method to delete all devices marked for deletion.#
	#######################################################################################
	Param (
		[Parameter(Mandatory = $true)]
		$InputData
	)
	
	Write-Log -Message "Start UEM API REST method - POST (Deleting devices)."
	
	try
	{
		$Body = @"
{
    "BulkValues": {
        "Value":[$($InputData)]
    }
}
"@
		Invoke-RestMethod -Uri "https://$server/api/mdm/devices/bulk" -Method POST -Headers $global:hdrs -ContentType "application/json" -Body $Body
		
	}
	catch
	{
		$ErrorType = $_.Exception.GetType()
		$ErrorCode = $_.Exception.Response.StatusCode.value__
		$ErrorDescription = $_.Exception.Response.StatusDescrip
		Write-Log -Message "An error occurred: Error Type: $ErrorType, Error Code:$ErrorCode, Error Description:$ErrorDescription"
	}
	Write-Log -Message "Finish UEM API REST method - POST (Deleting devices)."
}

function Create-Folder
{
	
	######################################################################################
	#This function will create a new folder every time when UEM maintenance is triggered.#
	#Folder name will be the format 'Win_(Date)'.                                        #
	#All files are going to be saved in this folder.                                     #
	######################################################################################
	Write-Log -Message "Checking if export folder $ExportFileLocation exists."
	
	
	If ((Test-Path $ExportFileLocation) -eq $false)
	{
		Write-Log "Folder doesn't exist. Creating folder..."
		md $ExportFileLocation
	}
	else
	{
		Write-Log -Message "Folder $ExportFileLocation exists"
	}
	
}


function Get-AllDevices
{
	
	
	If ((Test-Path $ExportFileLocation\$alldevice_csv))
	{
		Write-Log -Message "Existing $alldevice_csv file found in $ExportFileLocation\$alldevice_csv. Importing device list from there..."
		$devices = Import-Csv $ExportFileLocation\$alldevice_csv
		Write-Log -Message "Found $(@($devices.count)) devices."
		return $devices
	}
	else
	{
		Write-Log -Message "No $alldevice_csv file found in $ExportFileLocation\$alldevice_csv, getting all devices from $server..."
		$i = 0
		$devices = $null
		do
		{
			Write-Log "Querying page $i"
			$temp = (Invoke-RestMethod -Uri "https://$server/api/mdm/devices/search?platform=WinRT&page=$i&pagesize=30000" -Method Get -Headers $global:hdrs -ContentType "application/json").Devices
			$devices += $temp
			$i++
			
		}
		until ($temp -eq $null)
		
		Write-Log -Message "$(@($devices.count)) total devices were found from UEM via API"
		Write-Log -Message "Formatting data structure..."
		
		$output = foreach ($row in $devices) #formatting data. 
		{
			Try
			{
				$table = @{
					'UDID' = $row.udid
					'SerialNumber' = $row.SerialNumber
					'DeviceFriendlyName' = $row.DeviceFriendlyName
					'MACAddress' = $row.MacAddress
					'EnrollmentStatus' = $row.EnrollmentStatus
					'LastEnrolled' = ($row.LastEnrolledOn).Split('T')[0]
					'LastEnrolledTime' = ($row.LastEnrolledOn).Split('T')[1]
					'LastSeen' = ($row.LastSeen).Split('T')[0]
					'DeviceID' = $row.id.Value
					'Model' = $row.Model
					'UserEmail' = $row.UserEmailAddress
					'User' = $row.UserName
				}
				$obj = New-Object -TypeName PSObject -Property $table
			}
			catch
			{
				
			}
			$obj
			
		}
		
		$output | Export-Csv $ExportFileLocation\$alldevice_csv -NoTypeInformation -ErrorAction SilentlyContinue
		Write-Log -Message "$(@($devices.count)) total devices were exported to $ExportFileLocation\$alldevice_csv"
		return $output
	}
	
}

#############################
#	Starting Main Script	#
#############################

Write-Log -Message "Start Log"

Get-SecureCredentials
Create-Folder

switch ($Action)
{

	'Get-Duplicates' {
		Get-DuplicateDevices
		
	}
	'Delete-Duplicates' {
		Get-DuplicateDevices
		$deletions = Format-DevicesForDelete -InputData ($global:DuplicatesToBeDeleted)
		Delete-DevicesFromUEM -InputData $deletions
	}
	'Get-Stale' {
		Get-StaleDevices
	}
	'Delete-Stale' {
		Get-StaleDevices
		$deletions = Format-DevicesForDelete -InputData ($global:StaleToBeDeleted)
		Delete-DevicesFromUEM -InputData $deletions
		
	}
	'Get-Problematic' {
		Get-ProblematicDevices
	}
	'Delete-Problematic' {
		Get-ProblematicDevices
		$deletions = Format-DevicesForDelete -InputData (${global:ProblematicToBeDeleted})
		Delete-DevicesFromUEM -InputData $deletions
	}
}
