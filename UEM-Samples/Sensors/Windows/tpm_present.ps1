# Description: Returns True/False whether there is a TPM on the current computer
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$tpm=get-tpm
$status = $tpm.TpmPresent
return $status
