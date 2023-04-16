
<#
.Synopsis
  This Powershell script migrates a device from One UEM environment into a second environment
.DESCRIPTION
   
.EXAMPLE
  .\UEMMigration.ps1
#>

[CmdletBinding()]
Param(
    [switch]$silent
)

# Script Vars
$SourceApiUsername = "APIUSERNAME"
$SourceApiPassword = "API_PASSWORD"
$SourceApiKey = "API_KEY"
$SourceURL = "SOURCE_SERVER_URL"

$DestinationURL = "ENROLLMENT_URL"
$DestinationOGName = "ENROLLMENT_OG_ID"
$StagingUsername = "STAGING_USERNAME"
$StagingPassword = "STAGING_PASSWORD"

$Global:ProgressPreference = 'SilentlyContinue'

<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '615,266'
$Form.text                       = "Device Migration Utility"
$Form.TopMost                    = $false

$Status_Label                    = New-Object system.Windows.Forms.Label
$Status_Label.text               = "Migration Status"
$Status_Label.AutoSize           = $true
$Status_Label.width              = 240
$Status_Label.height             = 10
$Status_Label.Anchor             = 'top,right,left'
$Status_Label.location           = New-Object System.Drawing.Point(260,53)
$Status_Label.Font               = 'Microsoft Sans Serif,10'

$StartButton                     = New-Object system.Windows.Forms.Button
$StartButton.text                = "Start Migration"
$StartButton.width               = 113
$StartButton.height              = 30
$StartButton.location            = New-Object System.Drawing.Point(485,217)
$StartButton.Font                = 'Microsoft Sans Serif,10'

$ContinueButton                  = New-Object system.Windows.Forms.Button
$ContinueButton.Text             = "Continue"
$ContinueButton.Width            = 113
$ContinueButton.Height           = 30
$ContinueButton.Location         = New-Object System.Drawing.Point(485,217)
$ContinueButton.Font             = 'Microsoft Sans Serif,10'

$CloseButton                     = New-Object system.Windows.Forms.Button
$CloseButton.text                = "Complete"
$CloseButton.width               = 113
$CloseButton.height              = 30
$CloseButton.visible             = $false
$CloseButton.enabled             = $false
$CloseButton.location            = New-Object System.Drawing.Point(485,217)
$CloseButton.Font                = 'Microsoft Sans Serif,10'

$StatusMessageLabel              = New-Object system.Windows.Forms.Label
$StatusMessageLabel.AutoSize     = $true
$StatusMessageLabel.width        = 25
$StatusMessageLabel.height       = 10
$StatusMessageLabel.AutoSize     = $true
$StatusMessageLabel.TextAlign    = 1
$StatusMessageLabel.location     = New-Object System.Drawing.Point(200,87)
$StatusMessageLabel.Font         = 'Microsoft Sans Serif,10'

$Form.controls.AddRange(@($Status_Label,$StartButton,$CloseButton,$StatusMessageLabel,$ContinueButton))

$CloseButton.Add_Click({ $Form.Close() })
$StartButton.Add_Click({ Migration })
$ContinueButton.Add_Click({ Continue-Migration })


<#
  This implementation uses Basic authentication.  See "Client side" at https://en.wikipedia.org/wiki/Basic_access_authentication for a description
  of this implementation.
#>
Function Create-BasicAuthHeader {

	Param(
		[Parameter(Mandatory=$True)]
		[string]$username,
		[Parameter(Mandatory=$True)]
		[string]$password
    )

	$combined = $username + ":" + $password
	$encoding = [System.Text.Encoding]::ASCII.GetBytes($combined)
	$encodedString = [Convert]::ToBase64String($encoding)

	Return "Basic " + $encodedString
}

<#
  This method builds the headers for the REST API calls being made to the AirWatch Server.
#>
Function Create-Headers {

    Param(
		[Parameter(Mandatory=$True)]
		[string]$authString,
		[Parameter(Mandatory=$True)]
		[string]$tenantCode,
		[Parameter(Mandatory=$True)]
        [string]$acceptType
    )

    $header = @{"Authorization" = $authString; "aw-tenant-code" = $tenantCode; "Accept" = $acceptType.ToString(); "Content-Type" = "application/json"}

    Return $header
}

function New-V2Headers {
    Param(
		[Parameter(Mandatory=$True)]
		[string]$authString,
		[Parameter(Mandatory=$True)]
		[string]$tenantCode
    )

    $header = @{"Authorization" = $authString; "aw-tenant-code" = $tenantCode; "Accept" = "application/json;version=2"; "Content-Type" = "application/json;version=2"}

    Return $header
}

function Get-AirWatchVersion {
    Param(
        [Parameter(Mandatory=$True)]
        [hashtable] $headers,
        $awServer
    )

    try {
        $endpoint = "$awServer/api/system/info"
	    $response = Invoke-RestMethod -Method Get -Uri $endpoint.ToString() -Headers $headers
        $version = $response.ProductVersion

    }
    catch [System.Net.WebException] {
        $response = $_.Exception.Response | ConvertTo-Json
        Write-Verbose "Querying AirWatch version ($endpoint) Failed! Exception :: $($_.Exception.Message)"
        Write-Verbose "RESPONSE :: $($_.Exception.Response | ConvertTo-Json)"
    }
    catch {
        $response = $null
        Write-Verbose "Get AirWatch Version failed :: $PSItem"
    }

    Write-Verbose "Get AirWatch Version response :: $response"
    return $version;
}

Function Invoke-AirWatchAPIRequest {

    [CmdletBinding()]
    Param(
        # Headers for API Call
        [Parameter(Mandatory=$True)]
        [hashtable]
        $headers,

        # REST API Verb (GET, PATCH)
        [Parameter(Mandatory=$True)]
        [string]
        $Verb,

        [Parameter(Mandatory=$True)]
        [string]
        $awURL
    )

    # If we are in verbose mode
    if ($global:isVerbose) {
        $response = Invoke-RestMethod -Method $Verb -Uri $awURL -Headers $headers -Verbose
    }
    else {
        $response = Invoke-RestMethod -Method $Verb -Uri $awURL -Headers $headers
    }

    Return $response
}

function Invoke-MDMCommand {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$deviceID,

        [Parameter(Mandatory=$True)]
        [string]$command,

        [Parameter(Mandatory=$True)]
        $headers,

        [Parameter(Mandatory=$True)]
        $awURL
    )

    $url = "$($awURL)/API/mdm/devices/$($deviceID)/commands?command=$($command)"

    Write-Host "Executing $($command) on Device ID = $($deviceID)"
    $res = Invoke-AirWatchAPIRequest -awURL $url -headers $headers -Verb POST
    return $res
}

function Get-DeviceInfo {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$deviceUDID,
        
        [Parameter(Mandatory=$True)]
        $headers,

        [Parameter(Mandatory=$True)]
        $awURL
    )

    $url = "$($awURL)/API/mdm/devices/$($deviceUDID)"
    $res = Invoke-AirWatchAPIRequest -awURL $url -headers $headers -Verb GET
    
    return $res
}

function Search-ForDevice {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$deviceUDID,
        
        [Parameter(Mandatory=$True)]
        $headers,

        [Parameter(Mandatory=$True)]
        $awURL
    )

    $url = "$($awURL)/API/mdm/devices/?searchBy=udid&id=$($deviceUDID)"
    $res = Invoke-AirWatchAPIRequest -awURL $url -headers $headers -Verb GET
    return $res
}

function Get-EnrollmentStatus {
    $output = $true;

    $OMADMPath = "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*"
    $Account = (Get-ItemProperty -Path $OMADMPath -ErrorAction SilentlyContinue).PSChildname

    $EnrollmentPath = "HKLM:\SOFTWARE\Microsoft\Enrollments\$Account"
    $EnrollmentUPN = (Get-ItemProperty -Path $EnrollmentPath -ErrorAction SilentlyContinue).UPN

    if($null -eq $EnrollmentUPN) {
        $output = $false
    }

    return $output
}

function Get-DeviceUDID {
    $udidPath = "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\MDMDeviceID"
    $udid = (Get-ItemProperty $udidPath).DeviceClientId
    return $udid
}

function Uninstall-App {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$uninstallString
    )

    try
		{
			Write-host "$uninstallString GUID found"
			Write-host "Uninstalling..."
			start-process -Wait "msiexec" -arg "/X $uninstallString /qn"
		}
		catch
		{
			Write-host $_.Exception
			Write-host "Issues with uninstalling $uninstallString"
		}
}

function Remove-Agent {
    $uninstallStringAirWatch64 = (Get-ItemProperty HKLM:\Software\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\* | where-Object { $_.DisplayName -like "Airwatch*" }).PSChildName
    $uninstallStringAirWatch32 = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where-Object { $_.DisplayName -like "Airwatch*" }).PSChildName
    $uninstallStringHub64 = (Get-ItemProperty HKLM:\Software\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\* | where-Object { $_.DisplayName -like "*Intelligent Hub*" }).PSChildName
    $uninstallStringHub32 = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where-Object { $_.DisplayName -like "*Intelligent Hub*" }).PSChildName
    
    if ($uninstallStringAirWatch64)
	{
        Uninstall-App -uninstallString $uninstallStringAirWatch64
	}
    
    if ($uninstallStringAirWatch32)
	{
		Uninstall-App -uninstallString $uninstallStringAirWatch32
    }
    
    if ($uninstallStringHub64) 
    {
        Uninstall-App -uninstallString $uninstallStringHub64
    }

    if ($uninstallStringHub32)
    {
        Uninstall-App -uninstallString $uninstallStringHub32
    }
}

Function Enroll-Device {
    Write-Host "Enrolling device into $DestinationURL"

    Try
	{
		Start-Process msiexec.exe -Wait -ArgumentList "/i AirwatchAgent.msi /quiet ENROLL=Y IMAGE=N SERVER=$DestinationURL LGNAME=$DestinationOGName USERNAME=$StagingUsername PASSWORD=$StagingPassword ASSIGNTOLOGGEDINUSER=Y /log $AWAGENTLOGPATH\AWAgent.log"
	}
	catch
	{
		Write-host $_.Exception
	}
}

Function Continue-Migration {

    Write-Host "Resuming Enrollment Process"
    $StatusMessageLabel.Text = "Resuming Enrollment Process"
    Start-Sleep -Seconds 1

    $ContinueButton.Enabled = $false

    Enroll-Device

    $enrolled = $false

    while($enrolled -eq $false) {
        $status = Get-EnrollmentStatus
        if($status -eq $true) {
            $enrolled = $status
            Write-Host "Device Enrollment is complete"
            $StatusMessageLabel.Text = "Device Enrollmentis complete"
            $ContinueButton.Visible = $false
            $CloseButton.Visible = $true
            $CloseButton.Enabled = $true
        } else {
            Write-Host "Waiting for enrollment to complete"
            $StatusMessageLabel.Text = "Waiting for enrollment to complete"
            Start-Sleep -Seconds 10
        }

        
    }
}


Function Migration {
    $StartButton.Enabled = $false
    Write-Host "Beginning Migration Process"
    $StatusMessageLabel.Text = "Beginning Migration Process"
    Start-Sleep -Seconds 1

    # If they passed the verbose arg, set the global var
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
      $global:isVerbose = $true
    }

    # Build API Headers
    $authString = Create-BasicAuthHeader -username $SourceApiUsername -password $SourceApiPassword
    $headers = Create-Headers -authString $authString -tenantCode $SourceApiKey -acceptType "application/json"
    Write-Verbose "Headers :: $($headers)"

    # Check API Version
    $version = Get-AirWatchVersion -headers $headers -awServer $SourceURL
    Write-Host "AirWatch Version is $($version)"

    # Check Enrollment Status
    $enrolled = Get-EnrollmentStatus
    Write-Host "Checking Device Enrollment Status"
    $StatusMessageLabel.Text = "Checking Device Enrollment Status"
    Start-Sleep -Seconds 1
    if($enrolled) {
        Write-Host "Device is enrolled...fetching UDID"
        $StatusMessageLabel.Text = "Device is enrolled...fetching UDID"
        Start-Sleep -Seconds 1
        # Get UDID
        $udid = Get-DeviceUDID

        Write-Host "Getting Device ID from WS1 UEM"
        $StatusMessageLabel.Text = "Getting Device ID from WS1 UEM"
        Start-Sleep -Seconds 1
        $idRes = Search-ForDevice -deviceUDID $udid -headers $headers -awURL $SourceURL
        $deviceId = $idRes.id.Value

        # Call Enterprise Wipe
        Write-Host "Calling EnterpriseWipe on the server"
        $StatusMessageLabel.Text = "Calling EnterpriseWipe on the server"
        Start-Sleep -Seconds 1
        $res = Invoke-MDMCommand -deviceID $deviceId -command "EnterpriseWipe" -headers $headers -awURL $SourceURL
        
        if($null -eq $res) {
            Write-Host "EnterpriseWipe Command failed"
            $StatusMessageLabel.Text = "EnterpriseWipe Command failed"
            Start-Sleep -Seconds 1
            Exit
        }

        $StatusMessageLabel.Text = "Removing Hub Application"
        Start-Sleep -Seconds 1

        Remove-Agent
        
        # Sleep for 30 seconds before checking
        Start-Sleep -Seconds 10
        Write-Host "Checking Enrollment Status"
        $StatusMessageLabel.Text = "Checking Enrollment Status"
        Start-Sleep -Seconds 1
        # Wait till complete
        while($enrolled) { 
            $status = Get-EnrollmentStatus

            if($status -eq $false) {
                Write-Host "Device is no longer enrolled into the Source environment"
                $StatusMessageLabel.Text = "Device is no longer enrolled into the Source environment"
                Start-Sleep -Seconds 1
                $enrolled = $false
            }

            Start-Sleep -Seconds 5
        }

    }

    # Once not enrolled - Run enrollment script.
    Write-Host "Checking connectivity to Destination Server"
    $StatusMessageLabel.Text = "Checking connectivity to Destination Server"
    Start-Sleep -Seconds 1
    $connectionStatus = Test-Connection -ComputerName $DestinationURL -Quiet
     
    if($connectionStatus -eq $true) 
    {
        Write-Host "Device has connectivity to the Destination Server"
        $StatusMessageLabel.Text = "Device has connectivity to the New Environment"
        
        Start-Sleep -Seconds 1
        
        Write-Host "Running Remove-Agent again to confirm agent is not installed"
        Start-Sleep -Seconds 1
        Remove-Agent
        
        

        Write-Host "Running Enrollment process"
        $StatusMessageLabel.Text = "Running Enrollment process"
        Start-Sleep -Seconds 1
        Enroll-Device


        $enrolled = $false

        while($enrolled -eq $false) {
            $status = Get-EnrollmentStatus
            if($status -eq $true) {
                $enrolled = $status
                Write-Host "Device Enrollment is complete"
                $StatusMessageLabel.Text = "Device Enrollment is complete"
                Start-Sleep -Seconds 1
                $StartButton.Visible = $false
                $ContinueButton.Visible = $false
                $CloseButton.Visible = $true
                $CloseButton.Enabled = $true
            } else {
                Write-Host "Waiting for enrollment to complete"
                $StatusMessageLabel.Text = "Waiting for enrollment to complete"
                Start-Sleep -Seconds 10
            }
        }

    } else 
    {
        Write-Host "Not connected to Wifi, showing UI notification to continue once reconnected"
        $StatusMessageLabel.Text = "Device cannot reach the new environment, please check network connectivity"
        Start-Sleep -Seconds 1
        # Update UI to have enrollment continue button
        $StartButton.Visible = $false
        $ContinueButton.Visible = $true
    }
}


Function Main {

    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        # Relaunch as an elevated process:
        Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
        exit
    }

    if($silent) {
        Write-Host "Running migration in the background"
        Migration
    } else {        
        Write-Host "Showing UI flow"
        $Form.ShowDialog()
    }
}

Main