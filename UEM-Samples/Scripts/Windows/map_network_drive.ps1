# Description: Map a network drive
# Execution Context: User
# Execution Architecture: EITHER64OR32BIT
# Timeout: 30
# Variables: driveletter,H; drivepath,\\server\share

New-PSDrive -Name $env:driveletter -Root $env:drivepath -PSProvider FileSystem -Scope Global -Persist