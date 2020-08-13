#!/bin/bash

#Required
domain=$1
commonname=$domain

#Change to your company details
#country=US
#state=Georgia
#locality=Atlanta
#organization=feuemlab.local
#organizationalunit=IT
#email=feuemlab@gmail.com

#Optional
password=password

#Directories
privatekeys=privatekeys
#certs=certs
#crl=crl
pfxfiles=pfxfiles


if [ -z "$domain" ]
then
    echo "Argument not present - FQDN"
    echo "Useage =  newCert.sh myserver.feuemlab.local"
    echo "[common name or fqdn of server eg. myserver.feuemlab.local]"

    exit 99
fi

echo "Generating key request for $domain"

#Generate a key
openssl genrsa -aes256 -passout pass:$password -out $privatekeys/$domain.key 4096

#Remove passphrase from the key. Comment the line out to keep the passphrase
echo "Removing passphrase from key"
openssl rsa -in $privatekeys/$domain.key -out $privatekeys/$domain.key -passin pass:$password

((printf "\n[SAN]\nbasicConstraints=CA:FALSE\nextendedKeyUsage=serverAuth\nsubjectAltName=DNS:%s,DNS:www.%s" "$commonname" "$commonname")>options.cnf)

#Create the request
echo "Creating CSR"
openssl req -new -sha256 -key $privatekeys/$domain.key -out requests/$domain.csr -passin pass:$password -subj "/CN=$commonname" \
-extensions SAN -config <(cat ./openssl.cnf ./options.cnf)

certpath=cacerts
mycert=( "$certpath"/*.crt )


#Sign the Cert
echo "Signing the certificate with the CA"
openssl ca -batch -passin pass:$password -config openssl.cnf -in requests/$domain.csr \
-extensions SAN -extfile <(cat ./openssl.cnf ./options.cnf) -out certs/$domain.crt

#-extensions SAN -extfile <(cat ./openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:$commonname,DNS:$commonname")) -out certs/$domain.crt \

# Verify the cert
echo "Verifying the cert and adding it to the serial number file"
openssl verify -CAfile $mycert certs/$domain.crt

#Create the PFX
echo "Creating PFX for Windows server"
openssl pkcs12 -export -in certs/$domain.crt -inkey $privatekeys/$domain.key -name "$domain-(expiration date)" -chain -CAfile $mycert \
-passin pass:$password -passout pass:$password -out $pfxfiles/$domain.pfx

#
#echo "---------------------------"
#echo "-----Below is your CSR-----"
#echo "---------------------------"
#echo
#cat requests/$domain.csr
#
#echo
#echo "---------------------------"
#echo "-----Below is your Key-----"
#echo "---------------------------"
#echo
#cat privatekeys/$domain.key
