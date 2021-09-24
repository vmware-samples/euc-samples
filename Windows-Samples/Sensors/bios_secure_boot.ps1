# Returns True/False if Secure Boot is Enabled or Disabled
# Return Type: Boolean
# Execution Context: System
try { $bios=Confirm-SecureBootUEFI }
catch { $false }
return $bios