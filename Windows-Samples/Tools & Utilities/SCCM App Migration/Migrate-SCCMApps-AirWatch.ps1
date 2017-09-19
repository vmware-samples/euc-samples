<# Migrate SCCMApps-AirWatch Powershell Script Help

  .SYNOPSIS
    This Powershell script allows you to automatically migrate SCCM applications over to AirWatch for management from the AirWatch console.
    MUST RUN AS ADMIN
    MUST UPDATE SCCM SITECODE
        
  .DESCRIPTION
    When run, this script will prompt you to select an application for migration. It then parses through the deployment details of the 
    application and pushes the application package to AirWatch. The script then maps all the deployment commands and settings over to the 
    AirWatch application record. MSIs are ported over as-is. Script deployments are ported over as ZIP folders with the correct execution 
    commands to unpack and apply them.      

  .EXAMPLE

    .\Migrate-SCCMApps-AirWatch.ps1 `
        -SCCMSiteCode "PAL:" `
        -AWServer "https://mondecorp.ssdevrd.com" `
        -userName "tkent" `
        -password "SecurePassword" `
        -tenantAPIKey "iVvHQnSXpX5elicaZPaIlQ8hCe5C/kw21K3glhZ+g/g=" `
        -groupID "652" `
        -Verbose

  .PARAMETER SCCMSiteCode
    The Site Code of the SCCM Server that the script can set the location to.

  .PARAMETER AWServer
    Server URL for the AirWatch API Server
  
  .PARAMETER userName
    An AirWatch account in the tenant is being queried.  This user must have the API role at a minimum.

  .PARAMETER password
    The password that is used by the user specified in the username parameter

  .PARAMETER tenantAPIKey
    This is the REST API key that is generated in the AirWatch Console.  You locate this key at All Settings -> Advanced -> API -> REST,
    and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access

  .PARAMETER groupID
    The groupID is the ID of the Organization Group where the apps will be migrated. The API key and admin credentials need to be authenticated
    at this Organization Group. The shorcut to getting this value is to navigate to https://<YOUR HOST>/AirWatch/#/AirWatch/OrganizationGroup/Details.
    The ID you are redirected to appears in the URL (7 in the following example). https://<YOUR HOST>/AirWatch/#/AirWatch/OrganizationGroup/Details/Index/7

#>

[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]$SCCMSiteCode,
        
        [Parameter(Mandatory=$True)]
        [string]$AWServer,

        [Parameter(Mandatory=$True)]
        [string]$userName,

        [Parameter(Mandatory=$True)]
        [string]$password,

        [Parameter(Mandatory=$True)]
        [string]$tenantAPIKey,

        [Parameter(Mandatory=$True)]
        [string]$groupID
)

Write-Verbose "-- Command Line Parameters --"
Write-Verbose ("Site Code: " + $SCCMSiteCode)
Write-Verbose ("Site Code: " + $AWServer)
Write-Verbose ("UserName: " + $userName)
Write-Verbose ("Password: " + $password)
Write-Verbose ("Tenant API Key: " + $tenantAPIKey)
Write-Verbose ("Endpoint URL: " + $groupID)
Write-Verbose "-----------------------------"
Write-Verbose ""

Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module
Import-Module .\SCCM-AirWatch\SCCM-AirWatch.ps1
Import-Module .\AirWatchAPI\AirWatchAPI.ps1
 
Set-Location $SCCMSiteCode # Set the current location to be the site code.

##Progress bar
Write-Progress -Activity "Application Export" -Status "Starting Script" -PercentComplete 10

##Get applicaion list via WMI
##$Applications = Get-WMIObject -ComputerName $SCCMServer -Namespace Root\SMS\Site_$SCCMSiteCode -Class "SMS_Application" | Select -unique LocalizedDisplayName | sort LocalizedDisplayName
$Applications = Get-CMApplication | Select LocalizedDisplayName | sort LocalizedDisplayName

##Application Import Selection Form
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Start Drawing Form. The form has some issues depending on the screen resolution. #Needs to be updated
$form1 = New-Object System.Windows.Forms.Form
$form1.Text = "Application Import"
$form1.Size = New-Object System.Drawing.Size(425,380)
$form1.StartPosition = "CenterScreen"

$OKButton1 = New-Object System.Windows.Forms.Button
$OKButton1.Location = New-Object System.Drawing.Point(300,325)
$OKButton1.Size = New-Object System.Drawing.Size(75,23)
$OKButton1.Text = "OK"
$OKButton1.DialogResult = [System.Windows.Forms.DialogResult]::OK
$OKButton1.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
$form1.AcceptButton = $OKButton1
$form1.Controls.Add($OKButton1)

$CancelButton1 = New-Object System.Windows.Forms.Button
$CancelButton1.Location = New-Object System.Drawing.Point(225,325)
$CancelButton1.Size = New-Object System.Drawing.Size(75,23)
$CancelButton1.Text = "Cancel"
$CancelButton1.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$CancelButton1.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
$form1.CancelButton = $CancelButton1
$form1.Controls.Add($CancelButton1)

$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10,5)
$label1.Size = New-Object System.Drawing.Size(280,20)
$label1.Text = "Select an application to import"
$form1.Controls.Add($label1)

$listBox1 = New-Object System.Windows.Forms.Listbox
$listBox1.Location = New-Object System.Drawing.Size(10,30)
$listBox1.Width = 400
$listBox1.Height = 296
$listBox1.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right

##Add items to form
foreach($Application in $Applications)
{
    [void] $ListBox1.Items.Add($Application.LocalizedDisplayName)
}

#Display form to Admin
$form1.Controls.Add($listBox1)
$form1.Topmost = $True
$result1 = $form1.ShowDialog()

# If a valid input is selected then set Application else quit
if ($result1 -eq [System.Windows.Forms.DialogResult]::OK)
{
    $SelectedApplication = $listBox1.SelectedItems
    $SelectedApplication = $SelectedApplication[0]
}
else
{
    exit
}

##Progress bar
Write-Progress -Activity "Application Export" `
    -Status "Searching for applications" `
	-PercentComplete 30

#Parse the Deployment details of the Selected application and deserialize.
$selectedAppObject = Get-CMApplication -Name $SelectedApplication
[xml]$SDMPackageXML = $selectedAppObject.SDMPackageXML

##Progress bar
Write-Progress -Activity "Application Export" -Status "Finalizing" -PercentComplete 40


#MAIN

#Extract the hashtable returned from the function
$awProperties = Extract-PackageProperties -SDMPackageXML $SDMPackageXML

#Generate Auth Headers from username and password
$deviceListURI = $baseURL + $bulkDeviceEndpoint
$restUserName = Create-BasicAuthHeader -username $userName -password $password

# Define Content Types and Accept Types
$useJSON = "application/json"
#$useOctetStream = "application/octet-stream" #NOT USED

#Build Headers
$headers = Create-Headers -authString $restUserName `
    -tenantCode $tenantCode `
	-acceptType $useJson `
	-contentType $useJson

# Extract Filename, configure Blob Upload API URL and invoke the API.
$uploadFileName = Split-Path $awProperties.FilePath -leaf
#Check Why this is done*****
$awProperties.Add("LocationGroupId", $groupID)

$networkFilePath = "Microsoft.Powershell.Core\FileSystem::" + $awProperties.FilePath
$blobUploadResponse = Upload-Blob -airwatchServer $AWServer `
    -filename $uploadFileName `
	-filepath $networkFilePath `
	-groupID $groupID `
	-headers $headers

##Progress bar
Write-Progress -Activity "Application Export" -Status "Finalizing" -PercentComplete 70
Write-Verbose $blobUploadResponse

# Extract Blob ID and store in the properties table.
$blobID = $blobUploadResponse.Value
$awProperties.Add("BlobID", $blobID)
$awProperties.Add("UploadFileName", $uploadFileName)

##Progress bar
Write-Progress -Activity "Application Export" `
    -Status "Exporting $SelectedApplication" `
	-PercentComplete 80

# Call function to map all properties from SCCM to AirWatch JSON.
$webReturn = Save-App -awServer $AWServer `
    -headers $headers `
	-appDetails $awProperties

##Progress bar
Write-Progress -Activity "Application Export" `
    -Status "Export of $SelectedApplication Completed" `
	-PercentComplete 100

Write-Verbose $webReturn

#Fin
Write-Output "End"