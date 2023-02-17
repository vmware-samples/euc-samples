# Description: Return the current logged on username.
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

[System.Security.Principal.WindowsIdentity]::GetCurrent().Name

