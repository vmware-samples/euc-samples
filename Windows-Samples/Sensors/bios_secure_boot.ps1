# Returns True/False if Secure Boot is Enabled or Disabled
# Return Type: Boolean
# Execution Context: Admin
$bios = Confirm-SecureBootUEFI
write-output $bios

