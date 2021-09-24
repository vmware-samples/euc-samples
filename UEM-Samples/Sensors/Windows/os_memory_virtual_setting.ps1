# Returns the current paging file
# Execution Context: User

$virtualsize = Get-WmiObject Win32_PageFileSetting | where name -EQ "C:\pagefile.sys" | select MaximumSize
if ($virtualsize -ne $null) {
Write-Output $virtualsize
 } 
 else {
  Write-Output ""
  }
