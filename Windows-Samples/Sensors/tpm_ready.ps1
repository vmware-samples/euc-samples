# Returns True/False whether TPM is Ready to be used
# Return Type: Boolean
# Execution Context: Admin
$tpm=get-tpm
echo $tpm.TpmReady