# Description: Get local hostname or computername
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

[System.Net.Dns]::GetHostName()
