# Description: Returns True/False whether the TPM is locked out
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

$tpm=get-tpm
$status = $tpm.LockedOut
return $status
