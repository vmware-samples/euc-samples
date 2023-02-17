# Description: Get local hostname or computername
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

[System.Net.Dns]::GetHostName()
