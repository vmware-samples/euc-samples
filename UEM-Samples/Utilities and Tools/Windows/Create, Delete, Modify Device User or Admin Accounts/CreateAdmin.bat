REM Add Local User IT with password
net user "IT" "P@ssw0rd" /add

REM Change IT to become an Admin
net localgroup "Administrators" "IT" /add