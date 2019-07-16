# Returns windows 10 common name, aka Release ID (i.e. 1803, 1809)
# Return Type: String
# Execution Context: System
$releaseID = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
return $releaseID
