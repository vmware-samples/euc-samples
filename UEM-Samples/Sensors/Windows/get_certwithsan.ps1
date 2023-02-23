# Description: Sensor to find certificate in CurrentUser with specific SAN and return TRUE | FALSE
# Execution Context: USER
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN

#Variables
$Issuer = "CN=VMWEUCEAUAT-ROOT-CA, DC=vmweuceauat, DC=local"
$SANlike = "*@vmweuceauat.com*"

$cert = Get-ChildItem -Path cert:\CurrentUser\My | Where-Object {$_.Issuer -like $Issuer} | Where-Object {$SAN = ($_.Extensions | Where-Object {$_.Oid.FriendlyName -eq "Subject Alternative Name"}).Format($false); $SAN -like $SANlike}
if($cert){
    return $true
} else {
    return $false
}