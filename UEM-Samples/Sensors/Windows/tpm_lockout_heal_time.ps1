# Returns time (string) for how long the TPM will be locked out, if it locks
# Return Type: String
# Execution Context: System
$tpm=get-tpm
write-output $tpm.LockoutHealTime