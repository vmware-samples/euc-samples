# Description: Returns Windows Edition (e.g. Enterprise, Education, Home, Professional)
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$os=Get-WindowsEdition -online
Return $os.Edition

