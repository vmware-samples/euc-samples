# Returns True/False whether there is a TPM on the current computer
# Return Type: Boolean
# Execution Context: Admin
$tpm=get-tpm
echo $tpm.TpmPresent