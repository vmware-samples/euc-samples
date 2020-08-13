#!/bin/bash

echo 'Please enter the Certificate Authority Name for the CA you are creating.\n'
echo 'This will become the filename of your CA certificates'
read caname
#caname=myca3
echo 'Please Answer All of the questions in as much detail as you like.\n'
echo 'The Answers will be shown in the certs you create.\n'

echo 'You are about to be asked to enter information that will be incorporated'
echo 'into your certificate request.'
echo 'What you are about to enter is what is called a Distinguished Name or a DN.'
echo 'There are quite a few fields but you can leave some blank'
echo 'For some fields there will be a default value,'
echo 'If you enter '.', the field will be left blank.'
echo '-----'
echo 'Country Name (2 letter code):'; read C
echo 'State or Province Name (full name):';read ST
echo 'Locality Name (eg, city) :';read L
echo 'Organization Name (eg, company) :'; read O
echo 'Organizational Unit Name (eg, section) :'; read OU
echo 'Common Name (eg, fully qualified host name) :'; read CN
echo 'Email Address :'; read emailAddress
#C=US
#ST=CA
#L=San
#O=Name
#OU=IT
#CN=myca3.com
#emailAddress=leon@myca3.com

password=password

mkdir ./cacerts
mkdir ./certs
mkdir ./crl
mkdir ./newcerts
mkdir ./pfxfiles
mkdir ./privatekeys
mkdir ./requests

cp -f ./opensslSample.cnf ./openssl.cnf
sed -i .bak "s/yourcaname/$caname/g" openssl.cnf
sed -i .bak "s/yourcountryname/$C/g" openssl.cnf
sed -i .bak "s/yourstatename/$ST/g" openssl.cnf
sed -i .bak "s/yourlocalityname/$L/g" openssl.cnf
sed -i .bak "s/yourorgname/$O/g" openssl.cnf
sed -i .bak "s/yourorgunitname/$OU/g" openssl.cnf
sed -i .bak "s/yourcommonname/$CN/g" openssl.cnf
sed -i .bak "s/youremailaddress/$emailAddress/g" openssl.cnf

openssl genrsa -aes256 -passout pass:$password -out  cacerts/$caname.key 4096
openssl req -newkey rsa:2048 -sha256 -x509 -days 1826 -key cacerts/$caname.key -out cacerts/$caname.crt -passin pass:password  -subj "/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=$CN/emailAddress=$emailAddress" -config openssl.cnf -extensions v3_ca
echo "1000" > serial
echo "1000" > crl/crlnumber
touch index.txt
echo "unique_subject = yes" > index.txt.attr
openssl ca -config openssl.cnf -passin pass:password -gencrl -out crl/$caname.crl.pem

./newCert.sh localhost

#To Revoke a certificate, type the following ( for the localhost certificate generated above )
#openssl ca -config openssl.cnf -revoke certs/localhost.crt

