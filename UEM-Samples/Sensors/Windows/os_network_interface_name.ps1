# Description: Returns the name (description) of the active network interface
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$physical_adapter = Get-NetAdapter -physical | Where-Object status -eq "up"
Return $physical_adapter.InterfaceDescription

