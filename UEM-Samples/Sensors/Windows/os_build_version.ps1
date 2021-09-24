# Returns windows 10 version e.g. 1803
# Return Type: String
# Execution Context: System
$releaseID = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
return $releaseID