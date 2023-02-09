#!/bin/bash

# GateKeeper Version Script -- attributed to https://gist.githubusercontent.com/rtrouton/d70170eb5cfc5410041931bff412c11d/raw/42ce26a3a4ae5851551a45043f7eb1c66458a506/check_latest_Xprotect_Gatekeeper_MRT_update.sh

identify_latest_update=$(/usr/bin/printf "%s\n" $(/usr/sbin/pkgutil --pkgs=".*XProtect.*") | sort -k1 | tail -1)

version_info=$(/usr/sbin/pkgutil --pkg-info-plist "$identify_latest_update" | /usr/bin/plutil -extract pkg-version xml1 - -o - | /usr/bin/xmllint --xpath 'string(//plist/string)' -)

# Read install date and translate it into human-readable output

install_date_info=$(/bin/date -r $(/usr/sbin/pkgutil --pkg-info-plist "$identify_latest_update" | /usr/bin/plutil -extract install-time xml1 - -o - | /usr/bin/xmllint --xpath 'string(//plist/integer)' - ) '+%Y-%m-%d')

echo $install_date_info"___"$version_info"___"$identify_latest_update

# Description: Return XProtect Info. Return XProtect install date, version and update info. 
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING