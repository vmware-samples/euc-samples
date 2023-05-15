# Description: This script restarts all network adapters
# Execution Context: System
# Execution Architecture: EITHER64OR32BIT
# Timeout: 30

Get-NetAdapter | Restart-NetAdapter
