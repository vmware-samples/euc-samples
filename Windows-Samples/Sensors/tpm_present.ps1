# Returns True/False whether there is a TPM on the current computer
# Return Type: Boolean
# Execution Context: System
$tpm=get-tpm
write-output $tpm.TpmPresent