# Queries the current logged in user windows SID from HKU. 
# Return Type: String
# Execution Context: System
# Execution Architecture: Auto
# Author: bpeppin, 2/24/20

New-PSDrive HKU Registry HKEY_USERS | out-null
$SID = (get-childitem HKU: | Where-Object { $_.Name -like "*S-1-12-1*" -or $_.Name -like "*S-1-5-21*" -And $_.Name -notlike "*_classes" }).Name
$SID = $SID.Split('\')[1]
Remove-PSDrive HKU

return $SID