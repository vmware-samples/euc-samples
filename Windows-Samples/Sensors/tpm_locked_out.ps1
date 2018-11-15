# Returns True/False whether the TPM is locked out
# Return Type: Boolean
# Execution Context: Admin
$tpm=get-tpm
echo $tpm.LockedOut