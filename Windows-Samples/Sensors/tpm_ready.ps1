# Returns True/False whether TPM is Ready to be used
# Return Type: Boolean
# Execution Context: System
$tpm=get-tpm
write-output $tpm.TpmReady