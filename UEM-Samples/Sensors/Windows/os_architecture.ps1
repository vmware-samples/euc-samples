# Description: Returns OS Architecture (32-bit or 64-bit)
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$os=(Get-WmiObject Win32_OperatingSystem)
Return $os.OSArchitecture

