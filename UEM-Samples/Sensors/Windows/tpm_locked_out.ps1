# Description: Returns True/False whether the TPM is locked out
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN

$tpm=get-tpm
$status = $tpm.LockedOut
return $status
