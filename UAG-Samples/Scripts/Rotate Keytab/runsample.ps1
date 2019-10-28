$spn         = "HTTP/kcdtest.airwlab.com@AIRWLAB.COM" 
$keytabfile  = "C:\kcdtest\kcdtest-keys.keytab"

$domain="AIRWLAB"
$username  = "cybrtest"
$newpassword = "VMwareUAG#4@"

New-Keytabfile -spn $spn -mapuser ($username + "@" + $domain) -newpassword $newpassword -keytabfile $keytabfile


$uaguser     = "admin"
$uagpassword = "VMware"
$uaghostname = "uag-mgt.airwlab.com"

Connect-UAG -username $uaguser -password $uagpassword -hostname $uaghostname

Import-KeyTab -keytabfile $keytabfile -principalname $spn

Update-IIS -username ($domain + "\" + $username) -password $newpassword
