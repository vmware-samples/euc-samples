# Description: Returns the sha256 hash of the hosts file on a system.
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

[string]$hostsFileHash
$hosts = "$($env:windir)\System32\drivers\etc\hosts"
if (test-Path $hosts)
{
    $hostsFileHash = Get-FileHash -Path $hosts -Algorithm:SHA256
    $FileHash = ($hostsFileHash.hash).trim()
    return $FileHash
}
else 
{$hostsFileHash = "Hosts file not located via Sensor"}

