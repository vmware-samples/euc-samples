# Description: Returns True/False if Secure Boot is Enabled or Disabled
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

try { $bios=Confirm-SecureBootUEFI }
catch { $false }
return $bios
