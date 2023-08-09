#!/bin/bash

# Description: Sensor to find certificates in the current user store that match a given subject search string and check if they are revoked.
# Remember to set the subject search string in the $subjectPattern variable.  This will search the subject for any instance of the string.
# If you are testing this, you can change the $testing variable to $true and it will log to a file in the temp directory and show it at the end.
# Execution Context: USER
# Return Type: STRING


# Variables
if [ -z "$subjectPattern" ]; then
    subjectPattern="vmware"
fi

# if testing is set to true then the script will create a log file in the users temp directory and open it when done
if [ -z "$testing" ]; then
    testing="false"
fi

# Check if testing mode is enabled
if [ "$testing" == "true" ]; then
    # create a log file to record the results in teh users temp directory
    testLogFile=$(mktemp)
    # rename to add the log extension
    mv "$testLogFile" "$testLogFile.log"
    # update the variable to include the extension
    testLogFile="$testLogFile.log"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Start of Test Log" > "$testLogFile"
fi


security find-certificate -a -c "$subjectPattern" -p ~/Library/Keychains/login.keychain > "${TMPDIR}certList.pem"
# create an array to hold the certificates
matchingCertificates=()
tempCert=""
while read -r line; do
    if [[ "$line" == "-----BEGIN CERTIFICATE-----" ]]; then
        tempCert="
$line"
    elif [[ "$line" == "-----END CERTIFICATE-----" ]]; then
        tempCert="$tempCert
$line"
        matchingCertificates+=("$tempCert")
        tempCert=""
    else
        tempCert="$tempCert
$line"
    fi
done < "${TMPDIR}certList.pem"



# Check if we found any certificates
if [ ${#matchingCertificates[@]} -eq 0 ]; then
    echo "No certificates were found for searchString $subjectPattern."

    if [ "$testing" == "true" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): No certificates were found for searchString $subjectPattern." >> "$testLogFile"
    fi

    exit 0
fi


# Parse and check each certificate
revokedCertificates=()

for cert in "${matchingCertificates[@]}"; do
    # Remove any leading or trailing whitespace (like newlines) from the certificate
#    cert=$(echo "$cert" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    tempCertFile=$(mktemp)
    echo "$cert" > "$tempCertFile"
    # get the serial number of the cert
    serialNumber=$(openssl x509 -noout -serial -in "$tempCertFile" | awk -F= '{print $2}')

    if [ "$testing" == "true" ]; then
        echo "Checking Cert with Serial Number: $serialNumber"
    fi

    # Log the certificate to check its content
    if [ "$testing" == "true" ]; then
        echo "Checking Cert with Serial Number: $serialNumber" >> "$testLogFile"
    fi

    # Extract CRL Distribution Points from the certificate
    if [ "$testing" == "true" ]; then
        crlUrls=$(echo "$cert" | openssl x509 -noout -text 2>> "$testLogFile" | grep "URI:" | awk -F'URI:' '{print $2}' | sed 's/^[[:space:]]*//')
    else
        crlUrls=$(echo "$cert" | openssl x509 -noout -text | grep "URI:" | awk -F'URI:' '{print $2}' | sed 's/^[[:space:]]*//')
    fi


    if [ $? -ne 0 ]; then
        echo "Error processing certificate. Check log for details."
        continue
    fi

    # Write the url of the CRL to the log file
    if [ "$testing" == "true" ]; then
        echo "CRL Distribution Points: $crlUrls" >> "$testLogFile"
    fi


    # Loop through each CRL and check the certificate against it
    for crlUrl in $crlUrls; do

        # If the crlUrl does not have the extension .crl then skip it
        if [[ "$crlUrl" != *.crl ]]; then
            continue
        fi

        # Get the CRL and check to see if the certificate is revoked
        crlPath=$(mktemp)

        # log the crl url and path
        if [ "$testing" == "true" ]; then
            printf "CRL URL: %s\nCRL Path: %s\nCRL PEM file path: %s.pem\n" "$crlUrl" "$crlPath" "$crlPath" >> "$testLogFile"
        fi

        curl -s "$crlUrl" > "$crlPath"
        if [ $? -ne 0 ]; then
            if [ "$testing" == "true" ]; then
                echo "Error downloading crl from $crlUrl. Check log for details." >> "$testLogFile"
            fi
            logger "Error downloading crl from $crlUrl. Check log for details."
            continue
        fi
        openssl crl -inform DER -in "$crlPath" -out "${crlPath}.pem" -outform PEM
        if [ $? -ne 0 ]; then
            if [ "$testing" == "true" ]; then
                echo "Error processing crl from $crlUrl. Check log for details." >> "$testLogFile"
            fi
            logger "Error processing crl from $crlUrl. Check log for details."
            continue
        fi

        # check if the serial number is in the CRL which means its revoked
        serialNumberRevoked=$(openssl crl -in "${crlPath}.pem" -inform PEM -noout -text | grep "$serialNumber" | awk -F'Serial Number:' '{print $2}')
        if [ $? -eq 0 ]; then
            if [ "$testing" == "true" ]; then
                echo "Certificate with serial number $serialNumber is not revoked." >> "$testLogFile"
            fi
        else
            if [ "$testing" == "true" ]; then
                echo "Certificate with serial number $serialNumberRevoked has been revoked." >> "$testLogFile"
            fi
            # write a warning the system log
            logger "Certificate with serial number $serialNumberRevoked has been revoked."
            # Add the certificate to the list of revoked certificates
            revokedCertificates+=("$serialNumber")
            # exit the loop since we found a revoked cert
            break
        fi

        # Cleanup
        rm "$crlPath"
        rm "${crlPath}.pem"

    done

    # Cleanup
    rm "$tempCertFile"

done

# Output the results
if [ ${#revokedCertificates[@]} -gt 0 ]; then
    echo "Revoked Certs with subject $subjectPattern: ${revokedCertificates[*]}"

    if [ "$testing" == "true" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Revoked Certs with subject $subjectPattern: ${revokedCertificates[*]}" >> "$testLogFile"
    fi
else
    echo "No certificates were revoked for searchString $subjectPattern."

    if [ "$testing" == "true" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): No certificates were revoked for searchString $subjectPattern." >> "$testLogFile"
    fi
fi

# Open the log file if in testing mode
if [ "$testing" == "true" ]; then
    open "$testLogFile"
fi
