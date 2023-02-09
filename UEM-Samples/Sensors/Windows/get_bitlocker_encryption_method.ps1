# Description: Returns Encryption Method C: drive. Return values include - Aes128, Aes256, XtsAes128, XtsAes256
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$EncryptionMethod = (Get-BitLockerVolume -MountPoint "C:").EncryptionMethod
return $EncryptionMethod
