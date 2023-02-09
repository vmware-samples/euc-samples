# Description: Returns the total size of a folder in MB
# Execution Context: SYSTEM | USER
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: INTEGER

$picturesfolder = [Environment]::GetFolderPath(“MyPictures”)
$folderInfo = Get-ChildItem $picturesfolder -Recurse -File | Measure-Object -Property Length -Sum
$folderSize = ($folderInfo.Sum/1MB)
return ([System.Math]::Round($folderSize))