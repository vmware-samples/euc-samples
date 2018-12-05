# Returns value data for the Reg Key
# Return Type: Depends (String, Boolean, Integer, DateTime)
# Execution Context: Depends (Admin, System, or User)
# Update the Registry Path, then update ValueName for the data you want to retrieve
$reg=Get-ItemProperty "HKLM:\Key Folder\Key Name"
write-output $reg.ValueName