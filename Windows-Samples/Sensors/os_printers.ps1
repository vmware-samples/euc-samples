# Returns the current list of network printers
# Execution Context: User
$Printers = (Get-Printer | where type -eq "Connection").Name -join ','
if ($Printers -ne $null) {
 Write-Output $Printers
 } else {
  Write-Output ""
}
