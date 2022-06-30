<#
Returns the sha256 hash of the hosts file on a system.

DATE        EDITOR          DESCRIPTION OF CHANGE
2022-06-27  Brian Deyo      Initial sensor script
2022-06-28  Brian Deyo      Removed non-standard hash detection. That will be better setup downstream.

#>

[string]$hostsFileHash
$hosts = "$($env:windir)\System32\drivers\etc\hosts"



if (test-Path $hosts) {
    $hostsFileHash = Get-FileHash -Path $hosts -Algorithm:SHA256
    $hostsFileHash = $hostsFileHash.hash 
}
else {
    $hostsFileHash = "Hosts file not located via Sensor"
}
return $hostsFileHash
