<#
.Synopsis
  This Powershell script checks for required network access and service configuration 
  in order for enrollment to work correctly
.DESCRIPTION
   When run, the script will check for access to necessary WS1 and Microsoft servers 
   and will also confirm that specific services are allowed to run. An HTML report can 
   be generated in the script working directory for review and the logs can also be collated for simpler review
.EXAMPLE
  .\Enrollment-Checker
.EXAMPLE
  .\Enrollment-Checker -generateHTMLReport
.EXAMPLE
  .\Enrollment-Checker -collectLogs
#>

[CmdletBinding()]
Param(
  [switch]$generateHTMLReport,
  [switch]$showReport,
  [switch]$collectLogs
)
function getServiceStatus() {
  Param(
    [string]$serviceName
  )

  $service = Get-Service -Name $serviceName | Select-Object Name, Status, StartType, DisplayName

  return $service
}

function checkNetworkStatus() {
  Param(
     [string]$connectionName
  )

  $443_status = Test-NetConnection -ComputerName $connectionName -Port 443

  $output = New-Object PSObject
  $output | Add-Member -MemberType NoteProperty -Name ConnectionName -Value $connectionName
  $output | Add-Member -MemberType NoteProperty -Name Status_443 -Value $443_status.TcpTestSucceeded

  return $output
}

function checkMSFTStoreConnection() {
  $req = [System.Net.WebRequest]::Create('https://www.microsoft.com/store/apps')
  $res = $req.GetResponse();
  return $res.StatusCode
}

function getMDMDeviceID() {
  return Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\MDMDeviceID | Select DeviceClientId
}

function getDeviceRootCertificate() {
  $rawCert = Get-ChildItem -Path cert:\LocalMachine -Recurse  -DNSName "*AWDeviceRoot*"

  $cert = New-Object PSObject
  $cert | Add-Member -MemberType NoteProperty -Name Thumbprint -Value $rawCert.Thumbprint
  $cert | Add-Member -MemberType NoteProperty -Name Subject -Value $rawCert.Subject
  $cert | Add-Member -MemberType NoteProperty -Name DNSName -Value $rawCert.DnsNameList
  $cert | Add-Member -MemberType NoteProperty -Name NotBefore -Value $rawCert.NotBefore
  $cert | Add-Member -MemberType NoteProperty -Name NotAfter -Value $rawCert.NotAfter

  return $cert
}

function checkMDMEnabledViaGPO() {
  $MDMObject = New-Object psobject
  $MDMObject | Add-Member -MemberType NoteProperty -Name DisableRegistration -Value "MDM Enrollment Enabled"
  $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM"

  if($(Test-Path $path)) {
    $mdm = Get-ItemProperty -Path $path
    $value = $mdm.DisableRegistration
    if($value -eq 1) {
     $MDMObject.DisableRegistration = "MDM Enrollment Disabled"
    } 
  }

  return $MDMObject
}

function collectLogs() {
  Write-Host "Collecting logs"
  $agentLogPath = "C:\ProgramData\Airwatch\UnifiedAgent\Logs"

  if($(Test-Path -Path $agentLogPath)) {
    Write-Host "Copying Agent logs to $($outputFolder)"
    Copy-Item -Path $agentLogPath -Recurse -Destination $outputFolder
  } else {
    Write-Host "Agent log path not found, ensure that the Agent is installed"
  }
}

function buildHtmlReport() {
  Param(
    $serviceData,
    $connectionData,
    $mdmEnabled,
    $mdmDeviceId,
    $deviceRootCert
  )

  
    $report = "<Title>Enrollment Report</Title>
<style>
body { background-color:#FFFFFF;
       font-family:Tahoma;
       font-size:12pt; }
td, th { border:1px solid black; 
         border-collapse:collapse; }
th { color:white;
     background-color:black; }
table, tr, td, th { padding: 2px; margin: 0px }
tr:nth-child(odd) {background-color: lightgrey}
tr:nth-child(even) {background-color: white}
table { width:95%;margin-left:5px; margin-bottom:20px;}
</style>
<h1>MDM Enrollment Troubleshooting report</h1>
"

    $serviceHtml = "<h2>Services</h2>"
    $serviceHtml += $serviceData | ConvertTo-Html -Fragment -As Table
    $report += $serviceHtml

    $connHtml = "<h2>Connection Status</h2>"
    $connHtml += $connectionData | ConvertTo-Html -Fragment -As Table
    $report += $connHtml

    $mdmEnabledHtml = "<h2>MDM Enabled</h2>"
    $mdmEnabledHtml += $mdmEnabled | ConvertTo-Html -Fragment
    $report += $mdmEnabledHtml

    $mdmIdHtml = "<h2>MDM Device ID</h2>"
    $mdmIdHtml += $mdmDeviceId | ConvertTo-Html -Fragment -As List
    $report += $mdmIdHtml

    $certHtml = "<h2>Device Root Cert</h2>"
    $certHtml += $deviceRootCert | ConvertTo-Html -Fragment
    $report += $certHtml

    # Formating
    $svcPattern = '(?s)<td>Disabled</td>'
    $svcPatternColor = '<td bgcolor=red>Disabled</td>'

    $report = $report -replace $svcPattern,$svcPatternColor

    $connPattern = '(?s)<td>False</td>'
    $connPatternColor = '<td bgcolor=red>False</td>'
    $report = $report -replace $connPattern, $connPatternColor

    $enabledPattern = '(?s)<td>MDM Enrollment Disabled</td>'
    $enabledPatternBadColor = '<td bgcolor=red>MDM Enrollment Disabled</td>'
    $report = $report -replace $enabledPattern, $enabledPatternBadColor

    return $report
}

#region Main

$outputFolder = "$($PSScriptRoot)\EnrollmentOutput"

if(!(Test-Path -Path $outputFolder)) {
    New-Item -Path $outputFolder -ItemType Directory
}


#Check for WindowsVersion to identify required Services
$winver = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseID
if ($winver -gt 1803){
	$services = @("dmwappushservice", "DmEnrollmentSvc", "DiagTrack", "Schedule")
}
else {
	$services = @("dmwappushsvc", "DmEnrollmentSvc", "DiagTrack", "Schedule")
}

# Not working connections
# Not doing for now https://ekop.intel.com/ekcertservice fails - ekop.intel.com works # notify.live.net # notify.windows.com
$networkComponents = @("inference.location.live.net", "login.live.com", "discovery.awmdm.com", "wns.windows.com", "has.spserv.microsoft.com", "bspmts.mp.microsoft.com")

Write-Host "Checking status for services"
$serviceData = @()
foreach($svc in $services) {
  $curr = getServiceStatus -serviceName $svc

  $serviceData += $curr
}

Write-Host "Checking status for required connections"
$connectionData = @()
foreach($con in $networkComponents) {
  $current = checkNetworkStatus -connectionName $con
  $connectionData += $current
}

$msftStoreData = checkMSFTStoreConnection
$msftStore = New-Object PSObject
$msftStore | Add-Member -MemberType NoteProperty -Name ConnectionName -Value "MSFTStoreAccess"
$msftStore | Add-Member -MemberType NoteProperty -Name Status_443 -Value $msftStoreData
$connectionData += $msftStore

Write-Host "Checking if MDM Enrollment is disabled in GPO"
$mdmEnabled = checkMDMEnabledViaGPO

Write-Host "Confirming that the client machine has an MDMDeviceID generated - This value is unique per machine"
$id = getMDMDeviceID

Write-Host "Checking for device root certificate, should be present if an enrollment attempt was made"
$cert = getDeviceRootCertificate

if($collectLogs) {
  Write-Host "Collecting logs to output directory"
  collectLogs
}

if($generateHTMLReport) {
  Write-Host "Generate HTML Report for review"
  $report = buildHtmlReport -serviceData $serviceData -connectionData $connectionData -mdmDeviceId $id -deviceRootCert $cert -mdmEnabled $mdmEnabled
  $outputPath = "$($outputFolder)\Enrollment_Ouput.html"
  $report | Out-File -FilePath $outputPath.ToString()
  
  if($showReport) {
    Invoke-Item $outputPath
  }
} else {
  Write-Host "Display results to the console window"

  Write-Host "Service Status"
  $serviceData

  Write-Host "Connection Status"
  $connectionData | Format-Table
  
  Write-Host "MDM Device ID"
  $id | Format-Table

  Write-Host "Device Root Certificate"
  $cert | Format-Table
}

#endregion