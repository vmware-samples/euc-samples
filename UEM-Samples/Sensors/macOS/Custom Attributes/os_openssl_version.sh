#!/bin/bash

ssl_version=$(openssl version | awk '{print $2}')

echo $ssl_version

# Description: Returns OpenSSL client version
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING