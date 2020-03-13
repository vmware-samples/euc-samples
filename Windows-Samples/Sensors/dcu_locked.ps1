# Returns boolean status if Dell Command | Update UI is Locked. If DCU is not installed, returns False.
# Return Type: Boolean
# Execution Context: System

$DCU=(Get-ItemProperty "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG" -ErrorVariable err -ErrorAction SilentlyContinue)
if ($err.Count -eq 0) {
 $DCU = $DCU.LockSettings
 $DCU = [System.COnvert]::ToBoolean($DCU)
}else{
 $DCU = $false
}
write-output $DCU