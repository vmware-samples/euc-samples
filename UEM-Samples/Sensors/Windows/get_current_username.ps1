# Description: Return the current logged on username.
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

[System.Security.Principal.WindowsIdentity]::GetCurrent().Name

