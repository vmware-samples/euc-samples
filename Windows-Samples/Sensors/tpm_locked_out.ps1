# Returns True/False whether the TPM is locked out
# Return Type: Boolean
# Execution Context: System
$tpm=get-tpm
write-output $tpm.LockedOut