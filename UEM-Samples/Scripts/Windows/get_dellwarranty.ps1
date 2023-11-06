<# 
  .SYNOPSIS
    This script gathers the Dell Warranty info on the current Dell device.
  .DESCRIPTION
    This script is deployed as a Workspace ONE Script with the $apikey and $apisecret variables. The script uses the
    Dell Tech Direct API to read the device and warranty related info for the device to the HKLM:\SOFTWARE\DELL\WARRANTY
    registry key. 
    Register for a Dell Tech Direct account for API access here - https://tdm.dell.com/portal

    The get_dellwarrantydays.ps1 and get_dellmachinetype.ps1 sensors are also deployed as a Workspace ONE Sensors. These sensors
    read the HKLM:\SOFTWARE\DELL\WARRANTY registry key and report back to Workspace ONE Intelligence. A Workspace ONE Intelligence
    dashboard can then be created to display the number of days until the warranty expires broken down by device model.

    Credit to https://github.com/connochio/Powershell.Modules/blob/master/Get-DellWarranty/Get-DellWarranty.psm1  
    Uses Dell Tech Direct API to gather Dell Warranty info on the current device.
    Example powershell module here - https://github.com/connochio/Powershell.Modules/blob/master/Get-DellWarranty/Get-DellWarranty.psm1
  .REQUIREMENTS
    Requires Dell Tech Direct API authentication APIKey and APISecret. These must be provided as variables to a Workspace ONE Script.
  .EXAMPLE
    .\get_dellwarranty.ps1
  .NOTES 
    Created:   	    August, 2023
    Created by:	    Phil Helmling, @philhelmling
    Modified by:    Radoslav Nachev, September 2023
    Organization:   VMware, Inc.
    Filename:       get_dellwarranty.ps1
    Forked from:    https://github.com/helmlingp/sensors
#>

# WS1 Scripts Variables
$ApiKey = $env:apikey
$ApiSecret = $env:apisecret

# Variables
$DeviceManufacturer = (Get-WmiObject -Class:Win32_ComputerSystem).Manufacturer
$registryPath = "HKLM:\SOFTWARE\DELL\WARRANTY"

If ($DeviceManufacturer -like "*Dell*") {
  If (!$ApiKey -and !$ApiSecret) {
    # Can't do anything without the ApiKey
    Exit
  } Else {
    If (-NOT (Test-Path $registryPath)) {
      # Create the registry key
      New-Item $registryPath | Out-Null

      # Make API call to Dell Tech Direct
      [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      $Auth = Invoke-WebRequest "https://apigtwb2c.us.dell.com/auth/oauth/v2/token?client_id=${ApiKey}&client_secret=${ApiSecret}&grant_type=client_credentials" -Method Post
      $AuthSplit = $Auth.Content -split('"')
      $AuthKey = $AuthSplit[3]

      $ServiceTag = ((Get-WmiObject -Class "Win32_Bios").SerialNumber)

      $body = "?servicetags=" + $ServiceTag + "&Method=Get"
      $response = Invoke-WebRequest -uri https://apigtwb2c.us.dell.com/PROD/sbil/eapi/v5/asset-entitlements${body} -Headers @{"Authorization"="bearer ${AuthKey}";"Accept"="application/json"}
      $content = $response.Content | ConvertFrom-Json

      #get data in response, format and return warranty end date
      #Sort, then parse the first (start) and last (end) warranty entitlement
      $sortedEntitlements = $content.entitlements | Sort endDate #Dell doesn't list in order. This sorts so the latest entitlement is last.
      $WarrantyEndDateRaw = (($sortedEntitlements.endDate | Select -Last 1).split("T"))[0]
      $WarrantyEndDate = [datetime]::ParseExact($WarrantyEndDateRaw, "yyyy-MM-dd", $null)
      $WarrantyStartDateRaw = (($sortedEntitlements.startDate | Select -Last 1).split("T"))[0]
      $WarrantyStartDate = [datetime]::ParseExact($WarrantyStartDateRaw, "yyyy-MM-dd", $null)
      $ShipDateRaw = ($content.shipDate).Split(("T"))[0]
      $ShipDate = [datetime]$ShipDateRaw
      $Model = $content.productLineDescription
      $ServiceTagDell = $content.serviceTag
      $ServiceLevelDescription = ($sortedEntitlements.serviceLevelDescription | Select -Last 1)
      $ServiceLevelCode = ($sortedEntitlements.serviceLevelCode | Select -Last 1)
      $ServiceLevelGroup = ($sortedEntitlements.serviceLevelGroup | Select -Last 1)
      $ItemNumber = ($sortedEntitlements.itemNumber | Select -Last 1)

      #stamp the registry so we only do this once per machine and a sensor can read the info
      New-ItemProperty -Path $registryPath -Name 'WarrantyStartDate' -Value $WarrantyStartDate.ToUniversalTime() -PropertyType ExpandString -Force | Out-Null -ErrorAction SilentlyContinue
      New-ItemProperty -Path $registryPath -Name 'WarrantyEndDate' -Value $WarrantyEndDate.ToUniversalTime() -PropertyType ExpandString -Force | Out-Null -ErrorAction SilentlyContinue
      New-ItemProperty -Path $registryPath -Name 'ServiceLevelDescription' -Value $ServiceLevelDescription -PropertyType ExpandString -Force | Out-Null -ErrorAction SilentlyContinue
      New-ItemProperty -Path $registryPath -Name 'ServiceLevelCode' -Value $ServiceLevelCode -PropertyType ExpandString -Force | Out-Null -ErrorAction SilentlyContinue
      New-ItemProperty -Path $registryPath -Name 'ServiceLevelGroup' -Value $ServiceLevelGroup -PropertyType ExpandString -Force | Out-Null -ErrorAction SilentlyContinue
      New-ItemProperty -Path $registryPath -Name 'ItemNumber' -Value $ItemNumber -PropertyType ExpandString -Force | Out-Null -ErrorAction SilentlyContinue
      New-ItemProperty -Path $registryPath -Name 'Model' -Value $Model -PropertyType ExpandString -Force | Out-Null -ErrorAction SilentlyContinue
      New-ItemProperty -Path $registryPath -Name 'OriginalShipDate' -Value $ShipDate.ToUniversalTime() -PropertyType ExpandString -Force | Out-Null -ErrorAction SilentlyContinue
      New-ItemProperty -Path $registryPath -Name 'ServiceTag' -Value $ServiceTagDell -PropertyType ExpandString -Force | Out-Null -ErrorAction SilentlyContinue

    } Else {
      # We only run this once
    }
  }
} else {
  Exit
}