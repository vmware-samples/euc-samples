# Get number of days until Dell Warranty Expires
# Return Type: Integer
# Execution Context: System 
# Execution Architecture: Auto

$DeviceManufacturer = (Get-WmiObject -Class:Win32_ComputerSystem).Manufacturer
$registryPath = "HKLM:\SOFTWARE\DELL\WARRANTY"

If ($DeviceManufacturer -notlike "*Dell*") {
  return $null
} ElseIf (Test-Path $registryPath) {
  # Read the stored value and calculate the number of days from today
    $WarrantyEndDate = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Dell\WARRANTY' -Name 'WarrantyEndDate'
    $Today = Get-Date
    $TimeLine = New-TimeSpan -Start $Today -End $WarrantyEndDate
    return $TimeLine.Days
} Else {
  return $null
}
