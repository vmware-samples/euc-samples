# Description: Returns Dell Command Update Version
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$DCU=(Get-ItemProperty "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings" -ErrorVariable err -ErrorAction SilentlyContinue)
if ($err.Count -eq 0) {
 $DCU = $DCU.ProductVersion
}else{
 $DCU = "Dell Command | Update Not Installed"
}
return $DCU
