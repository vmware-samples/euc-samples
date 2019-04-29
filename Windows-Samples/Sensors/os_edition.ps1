# Returns Windows 10 Edition (e.g. Enterprise, Education, Home, Professional)
# Return Type: String
# Execution Context: System
$os=Get-WindowsEdition -online
write-output $os.Edition