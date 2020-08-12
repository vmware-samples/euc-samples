#!/bin/bash

nessus_version=$(/Library/NessusAgent/run/sbin/nessuscli --version | grep nessuscli)

echo $nessus_version