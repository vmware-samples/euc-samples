#!/bin/bash

creds=$(echo "$1" | cut -d '|' -f 1)
LGID=$(echo "$1" | cut -d '|' -f 2)
apikey=$(echo "$1" | cut -d '|' -f 3)
url=$(echo "$1" | cut -d '|' -f 4)

CurrentUser=`/usr/bin/stat -f%Su /dev/console`
currDate=$(date +"%Y-%m-%d_%H-%M-%S")
fileName="$CurrentUser-HubLogs-$currDate"

mkdir -p "/tmp/Workspace ONE/$fileName"
mkdir -p "/tmp/Workspace ONE/$fileName/Data"
mkdir -p "/tmp/Workspace ONE/$fileName/Munki"
mkdir -p "/tmp/Workspace ONE/$fileName/Daemon"
mkdir -p "/tmp/Workspace ONE/$fileName/User"

cp -rf "/Library/Application Support/AirWatch/Data/CustomAttributes" "/tmp/Workspace ONE/$fileName/Data/CustomAttributes"
cp -rf "/Library/Application Support/AirWatch/Data/CustomAttributesCache" "/tmp/Workspace ONE/$fileName/Data/CustomAttributesCache"
cp -rf "/Library/Application Support/AirWatch/Data/Munki" "/tmp/Workspace ONE/$fileName/Data/Munki"
rm -f "/tmp/Workspace ONE/$fileName/Data/Munki/Managed Installs/b.receiptdb"
cp -rf "/Library/Application Support/AirWatch/Data/ProductsNew" "/tmp/Workspace ONE/$fileName/Data/ProductsNew"
cp -f "/Library/Application Support/AirWatch/Data/AppStatuses_WS1.plist" "/tmp/Workspace ONE/$fileName/Data/AppStatuses_WS1.plist"

cp -f "/Library/Application Support/AirWatch/Data/Munki/Managed Installs/Logs/ManagedSoftwareUpdate.log" "/tmp/Workspace ONE/$fileName/Munki/ManagedSoftwareUpdate.log"
cp -f "/Library/Application Support/AirWatch/Data/Munki/Managed Installs/Logs/install.log" "/tmp/Workspace ONE/$fileName/Munki/install.log"

cp -rf "/Library/Logs/IntelligentHub" "/tmp/Workspace ONE/$fileName/Daemon/Logs"

cp -rf "/Users/$CurrentUser/Library/Logs/IntelligentHub" "/tmp/Workspace ONE/$fileName/User/Logs"

cd "/tmp/Workspace ONE/"
zip -rqX "$fileName.zip" "$fileName"

category="0"
categoryJSON=$(curl -X GET --header 'Content-Type: application/json' --header 'Accept: application/json' --header "Authorization: Basic $creds" --header "aw-tenant-code: $apikey" "$url/API/mcm/categories?locationgroupid=$LGID" 2>/dev/null)

i=1
substring=`echo "$categoryJSON" | cut -d '{' -f $i`
while [ -n "$substring" ]
do
	if echo "$substring" | grep -q "macOS Logs"; then
		tmp=${substring##*\"categoryId\":}
		category=${tmp:1:36}
		#echo "Found existing category: $category"
		break
	fi
	i=$((i + 1))
    substring=`echo "$categoryJSON" | cut -d '{' -f $i`	
done

if [ "$category" == "0" ]; then
	echo "No existing category"

	categoryJSON=$(curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header "Authorization: Basic $creds" --header "aw-tenant-code: $apikey" -d "{ \"name\": \"macOS Logs\", \"hasSubCategories\": false, \"locationGroupId\": $LGID }" "$url/API/mcm/categories" 2>/dev/null)

	tmp=${categoryJSON##*\"categoryId\":}
	category=${tmp:1:36}
	#echo "Created new category: $category"
fi

if [ "$category" != "0" ]; then
	fileJSON=$(curl -v -X POST --header 'Content-Type: application/octet-stream' --header 'Accept: application/json' --header "Authorization: Basic $creds" --header "aw-tenant-code: $apikey" --data-binary "@/tmp/Workspace ONE/$fileName.zip" "$url/API/mcm/api/AwContentV2?fileName=$fileName.zip&categoryId=$category&effectiveDate=2500-01-01T12%3A00%3A00.000&locationGroupId=$LGID" 2>/dev/null)
fi

rm -rf "/tmp/Workspace ONE/$fileName"
rm -f "/tmp/Workspace ONE/$fileName.zip"
rm -f "/tmp/Workspace ONE/CreateHubLogs/tempinfo"