# Returns time (string) for how long the TPM will be locked out, if it locks
# Return Type: String
# Execution Context: Admin
$tpm=get-tpm
echo $tpm.LockoutHealTime