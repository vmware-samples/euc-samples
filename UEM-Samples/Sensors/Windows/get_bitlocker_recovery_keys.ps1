# Description: Return Bitlocker Recovery Keys for each volume
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

# Identify all the Bitlocker volumes.
$BitlockerVolumers = Get-BitLockerVolume
# For each volume, get the RecoveryPassowrd and display it.
$bitlockercodes = @();
$BitlockerVolumers |
    ForEach-Object {
        $MountPoint = $_.MountPoint 
        $RecoveryKey = [string]($_.KeyProtector).RecoveryPassword
        if ($RecoveryKey.Length -gt 5) {
            $bitlockercodes += "$MountPoint,$RecoveryKey"
            return ("The drive $MountPoint has a recovery key $RecoveryKey.")
        }        
    }
$bitlockercodes = $bitlockercodes.ToString()

if($bitlockercodes){return $bitlockercodes}
