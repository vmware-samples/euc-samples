# Description: Returns Encryption Method C: drive. Return values include - Aes128, Aes256, XtsAes128, XtsAes256
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$EncryptionMethod = (Get-BitLockerVolume -MountPoint "C:").EncryptionMethod
return $EncryptionMethod
