# Description: Forces an Update of the Group Policy Objects applied to this device
# Execution Context: System
# Execution Architecture: EITHER64OR32BIT
# Timeout: 120

$arguments = "/c gpupdate /force"
Start-Process -FilePath "cmd.exe" -ArgumentList $arguments -WindowStyle Hidden -Wait

