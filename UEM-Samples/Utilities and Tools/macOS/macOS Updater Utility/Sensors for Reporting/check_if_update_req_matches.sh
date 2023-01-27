#!/usr/bin/env bash

#compare version numbers of two OS versions or floating point numbers up to 3 dots
compare_numbers() {
    #echo "Comparing $1 and $2"
    IFS='.' read -r -a os1 <<< "$1"
    IFS='.' read -r -a os2 <<< "$2"

    counter=0

    if [[ "${#os1[@]}" -gt "${#os2[@]}" ]]; then
        counter="${#os1[@]}"
    else
        counter="${#os2[@]}"
    fi

    for (( k=0; k<counter; k++ )); do

        # If the arrays are different lengths and we get to the end, then whichever array is longer is greater
        if [[ "${os1[$k]:-}" ]] && ! [[ "${os2[$k]:-}" ]]; then
            echo "gt"
            return 0
        elif [[ "${os2[$k]:-}" ]] && ! [[ "${os1[$k]:-}" ]]; then
            echo "lt"
            return 0
        fi

        if [[ "${os1[$k]}" != "${os2[$k]}" ]]; then
            t1="${os1[$k]}"
            t2="${os2[$k]}"

            alphat1=${t1//[^a-zA-Z]}; alphat1=${#alphat1}
            alphat2=${t2//[^a-zA-Z]}; alphat2=${#alphat2}

            # replace alpha characters with ascii value and make them smaller for comparison
            if [[ "$alphat1" -gt 0 ]]; then
                temp1=""
                for (( j=0; j<${#t1}; j++ )); do
                    if [[ ${t1:$j:1} = *[[:alpha:]]* ]]; then
                        g=$(LC_CTYPE=C printf '%d' "'${t1:$j:1}")
                        g=$((g-40))
                        temp1="$temp1$g"
                    else
                        temp1="$temp1${t1:$j:1}"
                    fi

                done
                t1="$temp1"
            fi
            # replace alpha characters with ascii value and make them smaller for comparison
            if [[ "$alphat2" -gt 0 ]]; then
                temp2=""
                for (( j=0; j<${#t2}; j++ )); do
                    if [[ ${t2:$j:1} = *[[:alpha:]]* ]]; then
                        g=$(LC_CTYPE=C printf '%d' "'${t2:$j:1}")
                        g=$((g-40))
                        temp2="$temp2$g"
                    else
                        temp2="$temp2${t2:$j:1}"
                    fi

                done
                t2="$temp2"
            fi

            if [[ "$t1" -gt "$t2" ]]; then
                echo "gt"
                return 0
            elif [[ "$t1" -lt "$t2" ]]; then
                echo "lt"
                return 0
            fi
        fi
    done

    echo "eq"

}

# compares two numbers n1 > n2 including floating point numbers
gt() {
    result=$(compare_numbers "$1" "$2")
    if [[ "$result" == "gt" ]]; then
        return 0
    else
        return 1
    fi
}

# compares two numbers n1 > n2 including floating point numbers
lt() {
    result=$(compare_numbers "$1" "$2")
    if [[ "$result" == "lt" ]]; then
        return 0
    else
        return 1
    fi
}

# compares two numbers n1 >= n2 including floating point numbers
ge() {
    result=$(compare_numbers "$1" "$2")
    if [[ "$result" == "gt" ]]; then
        return 0
    elif [[ "$result" == "eq" ]]; then
        return 0
    else
        return 1
    fi
}

# compares two numbers n1 >= n2 including floating point numbers
le() {
    result=$(compare_numbers "$1" "$2")
    if [[ "$result" == "lt" ]]; then
        return 0
    elif [[ "$result" == "eq" ]]; then
        return 0
    else
        return 1
    fi
}

# compares two numbers n1 == n2 including floating point numbers
eq() {
    result=$(compare_numbers "$1" "$2")
    if [[ "$result" == "eq" ]]; then
        return 0
    else
        return 1
    fi
}



currentOS=$(sw_vers -productVersion)
currentUser=$(stat -f%Su /dev/console)
DeviceUpdateAvailMatchingRequestedUpdate=false

#Check ManagePlist
managedPlistFile="com.macOSupdater.settings.plist"
managedPlistPath="/Library/Managed Preferences/"
managedPlist="$managedPlistPath$managedPlistFile"
managedFileNotFound=false
if [[ ! -f "$managedPlist" ]]; then
    managedFileNotFound=true
    checkLocation="$managedPlistPath$currentUser/$managedPlistFile"
    if [[ -f "$checkLocation" ]]; then
        managedPlist="$checkLocation"
        managedFileNotFound=false
    fi
fi

if [[ "$managedFileNotFound" = true ]]; then
    echo "Managed Preferences file not found in default location nor for $currentUser: No Update Scheduled"
    exit 0
fi

updateVersion=""
# get productKey if needed
checkIfUpdateRequestMatch() {
    suPlist="/Library/Preferences/com.apple.SoftwareUpdate.plist"
    availUpdates=$(/usr/libexec/PlistBuddy -c "Print :LastUpdatesAvailable" "$suPlist")
    index=0
    while [ $index -lt $availUpdates ]; do
        updateVersion=$(/usr/libexec/PlistBuddy -c "Print :RecommendedUpdates:$index:Display\ Version" "$suPlist")
        curProductName=$(/usr/libexec/PlistBuddy -c "Print :RecommendedUpdates:$index:Display\ Name" "$suPlist")
        if eq "$updateVersion" "$desiredOS"; then
            DeviceUpdateAvailMatchingRequestedUpdate=true
        elif gt "$updateVersion" "$desiredOS"; then
            if [[ $curProductName == "macOS"* ]]; then
                DeviceUpdateAvailMatchingRequestedUpdate=false
            fi
        fi
        index=$((index + 1))
    done
}

#check if mac is already on desired version or higher
desiredOS=$(/usr/libexec/PlistBuddy -c "Print :desiredOSversion" "$managedPlist")
if ge "$currentOS" "$desiredOS"; then
    echo "Current OS is $currentOS and is greater than or equal to desired OS $desiredOS"
    exit 0
fi

#check if major update or minor
currentMajor=$(echo $currentOS | /usr/bin/cut -f1 -d ".")
desiredMajor=$(echo $desiredOS | /usr/bin/cut -f1 -d ".")
if eq "$currentMajor" "$desiredMajor"; then
    if le "$currentMajor" "11"; then
        checkIfUpdateRequestMatch
    fi

fi

if [[ $DeviceUpdateAvailMatchingRequestedUpdate == true ]]; then
    echo "Requested Update: $desiredOS Matches Available Update: $updateVersion"
elif [ -n "$updateVersion" ]; then
    echo "Device OS: $currentOS Requested Update: $desiredOS Does Not Match Available Update - $updateVersion on Device"
else
	echo "Device OS: $currentOS Requested Update: $desiredOS Does Not Match"
fi
