# Returns the total size of a folder in MB
# Return Type: Integer
# Execution Context: User
$picturesfolder = [Environment]::GetFolderPath(“MyPictures”)
$folderInfo = Get-ChildItem $picturesfolder -Recurse -File | Measure-Object -Property Length -Sum
$folderSize = ($folderInfo.Sum/1MB)
Write-output  ([System.Math]::Round($folderSize))