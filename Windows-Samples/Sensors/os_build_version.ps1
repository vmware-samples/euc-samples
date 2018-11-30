# Returns windows 10 version e.g. 1803
# Return Type: String
# Execution Context: User
$os=Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
write-output $os.ReleaseId