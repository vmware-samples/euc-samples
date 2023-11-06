# Get the Model of a Dell PC
# Return Type: String
# Execution Context: System 
# Execution Architecture: Auto

$DeviceManufacturer = (Get-WmiObject -Class:Win32_ComputerSystem).Manufacturer
$registryPath = "HKLM:\SOFTWARE\DELL\WARRANTY"

If ($DeviceManufacturer -notlike "*Dell*") {
  return $null
} ElseIf (Test-Path $registryPath) {
  # Read the stored value and calculate the number of days from today
    $Model = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Dell\WARRANTY' -Name 'Model'
    return $Model
} Else {
  return $null
}
