# Description: Returns True/False if Secure Boot is Enabled or Disabled
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

try { $bios=Confirm-SecureBootUEFI }
catch { $false }
return $bios
