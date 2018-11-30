# Returns Windows 10 Edition (e.g. Enterprise, Education, Home, Professional)
# Return Type: String
# Execution Context: Admin
$os=Get-WindowsEdition -online
write-host $os.Edition