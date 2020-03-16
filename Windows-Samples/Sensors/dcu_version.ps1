# Returns Dell Command Update Version
# Return Type: String
# Execution Context: System

$DCU=(Get-ItemProperty "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings" -ErrorVariable err -ErrorAction SilentlyContinue)
if ($err.Count -eq 0) {
 $DCU = $DCU.ProductVersion
}else{
 $DCU = "Dell Command | Update Not Installed"
}
write-output $DCU