# Description: Returns True/False whether TPM is Ready to be used
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

$tpm=get-tpm
$status = $tpm.TpmReady
return $status
