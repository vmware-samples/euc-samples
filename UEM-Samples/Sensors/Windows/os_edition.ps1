# Description: Returns Windows Edition (e.g. Enterprise, Education, Home, Professional)
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$os=Get-WindowsEdition -online
Return $os.Edition

