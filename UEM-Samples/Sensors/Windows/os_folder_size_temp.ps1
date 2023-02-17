# Description: Returns the total size of a defined folder in MB
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$folder = "C:\Temp"
$folderInfo = Get-ChildItem $picturesfolder -Recurse -File | Measure-Object -Property Length -Sum
$folderSize = ([System.Math]::Round(($folderInfo.Sum/1MB)))
Return "$folderSize MB"

