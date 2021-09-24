# Returns used virutal memory in kilobytes
# Return Type: Integer
# Execution Context: User
$virtualsize = Get-WmiObject Win32_PageFileSetting | where name -EQ "C:\pagefile.sys"
$size=$virtualsize.maximumsize
write-output $size
