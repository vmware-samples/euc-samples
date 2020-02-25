# Queries the current logged in user windows SID from HKU. 
# Return Type: String
# Execution Context: System
# Execution Architecture: Auto
# Author: bpeppin, 2/25/20

$temp = "HKU"
New-PSDrive $temp Registry HKEY_USERST -ErrorAction SilentlyContinue | out-null
$SID = (get-childitem HKL: -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*S-1-12-1*" -or $_.Name -like "*S-1-5-21*" -And $_.Name -notlike "*_classes" }).Name
Remove-PSDrive $temp
If ($SID)
{
$SID = $SID.Split('\')[1]
return $SID
}else{
return "No_logged_in_User"
}
