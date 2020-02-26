# Queries the current logged in user windows SID from HKU. 
# Return Type: String
# Execution Context: System
# Execution Architecture: Auto
# Author: bpeppin, 2/25/20

New-PSDrive HKU Registry HKEY_USERS -ErrorAction SilentlyContinue | out-null
$SID = (get-childitem HKU: -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*S-1-12-1*" -or $_.Name -like "*S-1-5-21*" -And $_.Name -notlike "*_classes" }).Name
Remove-PSDrive HKU
If ($SID)
{
$SID = $SID.Split('\')[1]

}else{
return "No_logged_in_User"
}