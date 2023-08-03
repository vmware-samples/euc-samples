#!/usr/bin/env bash

##################################
#
#
# Developed by: Matt Zaske, Leon Letto and others
# July 2022
#
# revision 12.1 (August 3, 2023)
#
# macOS Updater Utility (mUU):
# Designed to keep macOS devices on the desired OS version
# by utilizing Apples MDM commands
#
#
##################################

set -o errexit
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi
###SOF###logger.sh

##################################
#
# logger library for bash scripts
# Developed by: Leon Letto
# December 2022
#
# revision 1 (Jan 8, 2023)
#
#
# This script is used to log messages to the console and to a log file and is designed to be similar the API of the python
# logging module.
#
#
##################################

# Functions needed from my bashLibrary
#compare version numbers of two OS versions or floating point numbers up to 3 dots including up to 4 alpha characters
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


fileSize() {
    # Returns the file size in bytes even if it is on a mapped smb drive
    optChar='f'
    fmtString='%z'
    stat -$optChar "$fmtString" "$@"
}


CRITICAL=0
ERROR=1
WARNING=2
INFO=3
DEBUG=4
#_log_levels=(CRITICAL ERROR WARNING INFO DEBUG)
_log_to_screen=true _log_to_file=false _log_file_name="" _log_color_output=true _log_level=3 _log_rotation_count=5 _log_file_rotate_size=100000

dateTime="$(date +%Y/%m/%d) $(date +%T%z)" # Date format: YYYY/MM/DD HH:MM:SS+0000

#dateForFileName=$(date +%Y%m%d)
#timeForFileName=$(date +%H%M%S)



#function to rotate logs when they reach a certain size automatically using standard numbering
rotateLogs() {
    local logFile="$1"
    local logFileBaseName="${logFile%.*}"
    local logFileExtension="${logFile##*.}"
    local logFileRotateSize=$_log_file_rotate_size # 100000 bytes = 100 kilobytes
    currentSize="$(fileSize "$logFile")"

    local numberOfRotatedLogs=_log_rotation_count

    if ge "${currentSize}" "${logFileRotateSize}"; then
        for ((i=numberOfRotatedLogs; i>-1; i--)); do
            if [ -f "${logFileBaseName}.${logFileExtension}.${i}" ]; then
                if [ "$i" -eq $((numberOfRotatedLogs)) ]; then
                    rm "${logFileBaseName}.${logFileExtension}.${i}"
                else
                    mv "${logFileBaseName}.${logFileExtension}.$((i))" "${logFileBaseName}.${logFileExtension}.$((i+1))"
                    touch "${logFileBaseName}.${logFileExtension}.$((i))"
                fi
            elif [ -f "${logFileBaseName}.${logFileExtension}" ] && [ "$i" -eq "0" ]; then
                mv "${logFileBaseName}.${logFileExtension}" "${logFileBaseName}.${logFileExtension}.$((i+1))"
                touch "${logFileBaseName}.${logFileExtension}"
            fi
        done
    fi

}

log_rotation_count() {
    _log_rotation_count=$1
}

log_file_rotate_size() {
    if [ -n "$_log_file_name" ] && [ "$1" -ne $_log_file_rotate_size ]; then
        echo "log_file_rotate_size must be set before log_file_name or new size will not be used"
    else
        _log_file_rotate_size=$1
    fi

}


log_color_output() {
    if [[ "$1" == "true" ]]
    then
        _log_color_output=true
    else
        _log_color_output=false
    fi
}

log_level() {
    local level
    level=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    case $level in
        CRITICAL)
            _log_level=0
            ;;
        ERROR)
            _log_level=1
            ;;
        WARNING)
            _log_level=2
            ;;
        INFO)
            _log_level=3
            ;;
        DEBUG)
            _log_level=4
            ;;
        *)
            echo "Invalid log level: $level"
            exit 1
            ;;
    esac
}

what_level(){
    local level
    case $3 in
        CRITICAL)
            level=$CRITICAL
            ;;
        ERROR)
            level=$ERROR
            ;;
        WARNING)
            level=$WARNING
            ;;
        INFO)
            level=$INFO
            ;;
        DEBUG)
            level=$DEBUG
            ;;
        *)
            level=$INFO
            ;;
    esac
    echo $level
}

log_to_screen() {
    if [[ "$1" == "True" || "$1" == "true"  ]]; then
        _log_to_screen=true
    elif [[ "$1" == "False" || "$1" == "false" ]]; then
        _log_to_screen=false
    fi
}

log_file_name() {
    _log_file_name=$1
    if [ -n "$_log_file_name" ]; then
        _log_to_file=true
        # check if a filename contains a path
        if [[ "${_log_file_name}" == */* ]]; then
            # if it does, then create the directory if it doesn't exist
            if [ ! -d "${_log_file_name%/*}" ]; then
                mkdir -p "${_log_file_name%/*}"
            fi
        fi
        if [[ ! -f "$_log_file_name" ]]; then
            touch "$_log_file_name"
        else
            rotateLogs "$_log_file_name"
        fi
    else
        _log_to_file=false
    fi

}

set_logging() {
    if ! [[ "${1:-}" ]]
    then
        echo 'No log level specified - _log_level set to INFO'
    else
        log_level "$1"
    fi
    if ! [[ "${2:-}" ]]
    then
        echo 'logging to screen by default enabled'
    else
        log_to_screen "$2"
    fi

    if ! [[ "${3:-}" ]]
    then
#        _log_file_name="./ws1AdminApiLog.log"
#        printf 'No log file specified therefore default filename %s is used.\n' "${_log_file_name}"
#        log_file_name "${_log_file_name}"
        printf 'No log file specified therefore logging is to screen only by default'

    else
        log_file_name "$3"
    fi

}



export COLOR_BOLD="\033[1m"
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;34m"
COLOR_YELLOW="\033[0;33m"
COLOR_BLUE="\033[0;32m"
COLOR_OFF="\033[0m"


log_color() {
    if ! [[ "${1:-}" ]]
    then
        local level=$_log_level
    else
        local level="$1"
    fi

    local color
    case $level in
        CRITICAL)
            color=$COLOR_RED
            ;;
        ERROR)
            color=$COLOR_RED
            ;;
        WARNING)
            color=$COLOR_YELLOW
            ;;
        INFO)
            color=$COLOR_OFF
            ;;
        DEBUG)
            color=$COLOR_GREEN
            ;;
        *)
            color=$COLOR_OFF
            ;;
    esac
    echo -e "$color"
}



print_message() {
    local message
    message="$(echo "$@" | cut -f 4- -d ' ')"
    if [[ "$_log_to_screen" == "true" ]]; then
        if [[ "$_log_color_output" == "true" ]]; then
            printf '%s%s %s %s %s %s' "$(log_color "$1")" "${dateTime}" "$2" "$3" "$1" "$message"
            printf '%s\n' "$(log_color)"
        else
            printf '%s %s %s %s %s' "${dateTime}" "$2" "$3" "$1" "$message"
            printf '\n'
        fi

    fi
    if [[ "$_log_to_file" == "true" ]]; then
        printf '%s %s %s %s %s' "${dateTime}" "$2" "$3" "$1" "$message" >> "$_log_file_name"
        printf '\n' >> "$_log_file_name"
    fi

}

shopt -s expand_aliases
#This is a hack to get around the fact that aliases are not exported
#when a script is sourced.  This is a workaround to get around that.
#These aliases allow showing the details of the command from the calling file and the line number
alias log_critical='logger_critical ${BASH_SOURCE##*/} $LINENO '
alias log_error='logger_error ${BASH_SOURCE##*/} $LINENO '
alias log_warning='logger_warning ${BASH_SOURCE##*/} $LINENO '
alias log_info='logger_info ${BASH_SOURCE##*/} $LINENO '
alias log_debug='logger_debug ${BASH_SOURCE##*/} $LINENO '
alias log_cat_file='logger_cat_file ${BASH_SOURCE##*/} $LINENO '
alias log_info_file='logger_info_file ${BASH_SOURCE##*/} $LINENO '
alias log_execute='logger_execute ${BASH_SOURCE##*/} $LINENO '

logger_critical() { if ge $_log_level $CRITICAL; then print_message CRITICAL "$@";fi  }
logger_error()    { if ge $_log_level $ERROR; then  print_message ERROR "$@"; fi    }
logger_warning()  { if ge $_log_level $WARNING; then  print_message WARNING "$@"; fi    }
logger_info()     { if ge $_log_level $INFO; then  print_message INFO "$@"; fi  }
logger_debug()    { if ge $_log_level $DEBUG; then  print_message DEBUG "$@"; fi    }

# functions for logging command output - Sample functions
logger_cat_file()   { if ge $_log_level $DEBUG && [[ -f $3 ]];then print_message DEBUG "$1" "$2" "=== contents of $3 start ===" && cat "$3" && print_message DEBUG "$1" "$2" "=== contents of $3 end ==="; fi }
logger_info_file()    { if ge $_log_level $INFO  && [[ -f $3 ]];then print_message INFO "$1" "$2" "=== file details of $3 start ===" && ls -l "$3" && print_message INFO "$1" "$2" "=== file details of $3 end ==="; fi }
logger_execute() {
    local message
    message="$(echo "$@" | cut -f 4- -d ' ')"
    local level
    case $3 in
        CRITICAL)
            level=$CRITICAL
            ;;
        ERROR)
            level=$ERROR
            ;;
        WARNING)
            level=$WARNING
            ;;
        INFO)
            level=$INFO
            ;;
        DEBUG)
            level=$DEBUG
            ;;
        *)
            level=$INFO
            ;;
    esac
    if ge $_log_level $level; then
        print_message "$3" "$1" "$2"  "=== output of $message start ==="
        "${@:4}"
        print_message "$3" "$1" "$2"  "=== output of $message end ==="
    else
        "${@:4}" >/dev/null
    fi
}

###EOF###logger.sh

###SOF###macOSupdater.sh

#set Variables
counterFile="/private/var/macOSupdater/mu_properties.plist"
logLocation="/Library/Logs/macOSupdater.log"
ws1Log="/Library/Application Support/AirWatch/Data/ProductsNew/"
currentOS=$(sw_vers -productVersion)
currentUser=$(stat -f%Su /dev/console)
currentUID=$(id -u "$currentUser")
serial=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
uuid=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformUUID/{print $(NF-1)}' | tr '[:lower:]' '[:upper:]' | tr -d '-')
#variables set via WS1
# $clientID
# $clientSec
# $apiURL
# $tokenURL
proxy=""

### functions

#convert version number to individual
function version { echo "$@" | /usr/bin/awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }


# Logging Function for reporting actions
log() {
    DATE=$(date +%Y-%m-%d\ %H:%M:%S)
    LOG="$logLocation"
    echo "$DATE" " $1" >>$LOG
}

gatherLogs() {
    # extract directory from $counterFile
    tmp_dir="/private/var/tmp"
    tmp_log_dir="/private/var/tmp/macOSupdaterLogs"
    dateForFileName=$(date +%Y%m%d_%H:%M)
    log_info "Gathering Logs and saving for analysis"

    softwareUpdatedLog="${tmp_dir}/install.log"
    # create directory if it does not exist
    if [ ! -d "$tmp_log_dir" ]; then
        mkdir -p "$tmp_log_dir"
    fi
    if [ -f "$managedPlist" ]; then
        cp "$managedPlist" "$tmp_log_dir"
    fi
    if [ -f "$counterFile" ]; then
        cp "$counterFile" "$tmp_log_dir"
    fi
    if [ -f "$logLocation" ]; then
        cp "$logLocation" "$tmp_log_dir"
    fi
    if [ -f "$softwareUpdatedLog" ]; then
        cp "$softwareUpdatedLog" "$tmp_log_dir"
    fi
    if [ -f "installStatus.sh" ]; then
        cp "installStatus.sh" "$tmp_log_dir"
    fi
    machineDetails="{\"serial\":\"$serial\",\"UUID\":\"$uuid\",\"os\":\"$currentOS\",\"user\":\"$currentUser\",\"uid\":\"$currentUID\"}"
    echo "$machineDetails" >"$tmp_log_dir/machineDetails.json"
    # zip up the logs
    zip -qr "$tmp_dir/macOSupdaterLogs$dateForFileName.zip" "$tmp_log_dir"
    # remove logs older than 48 hours
    find "$tmp_dir" -name "macOSupdaterLogs*.zip" -type f -mtime +2 -exec rm {} \;
    # remove the logs
    rm -rf "$tmp_log_dir"
    # move the zip to the hub log directory
    mv "$tmp_dir/macOSupdaterLogs$dateForFileName.zip" "$ws1Log"
    log_info "Logs saved to $ws1Log"
    exit 0
}

# get productKey if needed
getProductKey() {
    desiredProductKey=""
    suPlist="/Library/Preferences/com.apple.SoftwareUpdate.plist"
    if [[ "$1" == "major" ]]; then
        desiredProductKey="_MACOS_"$desiredOS
    elif [[ "$rsrMode" == 1 ]]; then
      declare -a rsrKeys=($(/usr/libexec/PlistBuddy -c "Print :ManagedProductKeys" "$suPlist" 2>/dev/null | /usr/bin/sed -e 1d -e '$d' || :))
      subString=$desiredOS"_rsr"
      ## now loop through the above array
      for key in "${rsrKeys[@]}"
      do
         if [[ "$key" == *"$subString" ]]; then
           desiredProductKey=$key
           log_info "product key found for $desiredOS RSR: $desiredProductKey"
           break
         fi
      done

      availUpdates=$(/usr/libexec/PlistBuddy -c "Print :LastUpdatesAvailable" "$suPlist")
      index=0
      while [ $index -lt $availUpdates ]; do
          updateVersion=$(/usr/libexec/PlistBuddy -c "Print :RecommendedUpdates:$index:Display\ Version" "$suPlist")
          desiredVersion="$desiredOS $rsrVersion"
          if [[ "$desiredVersion" == "$updateVersion" ]]; then
              desiredProductKey=$(/usr/libexec/PlistBuddy -c "Print :RecommendedUpdates:$index:Product\ Key" "$suPlist")
              log_info "product found for $updateVersion: $desiredProductKey"
              break
          fi
          index=$((index + 1))
      done

      if [ "$desiredProductKey" = "" ]; then
          log_info "No product key found, kickstarting softwareupdate and will retry on the next run"
          sudo launchctl kickstart -k system/com.apple.softwareupdated
      fi
    else
        # osBuild=$(/usr/bin/plutil -p /Library/Updates/ProductMetadata.plist | /usr/bin/grep -w -B 1 "$desiredOS" | /usr/bin/awk 'NR==1{print $3}' | /usr/bin/tr -d '"')
        # desiredProductKey="MSU_UPDATE_"$osBuild"_patch_"$desiredOS
        availUpdates=$(/usr/libexec/PlistBuddy -c "Print :LastUpdatesAvailable" "$suPlist")
        index=0
        while [ $index -lt $availUpdates ]; do
            updateVersion=$(/usr/libexec/PlistBuddy -c "Print :RecommendedUpdates:$index:Display\ Version" "$suPlist")
            curProductName=$(/usr/libexec/PlistBuddy -c "Print :RecommendedUpdates:$index:Display\ Name" "$suPlist")
            if [[ $(version $updateVersion) -eq $(version $desiredOS) ]]; then
                desiredProductKey=$(/usr/libexec/PlistBuddy -c "Print :RecommendedUpdates:$index:Product\ Key" "$suPlist")
                log_info "product found for  $curProductName $updateVersion: $desiredProductKey"
                break
            elif [[ $(version $updateVersion) -gt $(version $desiredOS) ]]; then
                if [[ $curProductName == "macOS"* ]]; then
                    desiredProductKey=$(/usr/libexec/PlistBuddy -c "Print :RecommendedUpdates:$index:Product\ Key" "$suPlist")
                    log_info "product found for  $curProductName $updateVersion: $desiredProductKey"
                    break
                fi

                log_info "index $index update not matching $desiredOS. Found $curProductName $updateVersion."
            fi
            index=$((index + 1))
        done
        if [ "$desiredProductKey" = "" ]; then
            log_info "No product key found, attempting to create using build info"
            osBuild=$(/usr/bin/plutil -p /Library/Updates/ProductMetadata.plist | /usr/bin/grep -w -B 1 "$desiredOS" | /usr/bin/awk 'NR==1{print $3}' | /usr/bin/tr -d '"')
            desiredProductKey="MSU_UPDATE_"$osBuild"_patch_"$desiredOS
            log_info "product created for $updateVersion: $desiredProductKey"
            sudo launchctl kickstart -k system/com.apple.softwareupdated
        fi
    fi
    echo "$desiredProductKey"
}

# generate oAuth token
getToken() {
    #request access token
    if [ -n "$proxy" ]; then
        oAuthToken=$(/usr/bin/curl -x $proxy -X POST $tokenURL -H "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=client_credentials&client_id=$1&client_secret=$2")
    else
        oAuthToken=$(/usr/bin/curl -X POST $tokenURL -H "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=client_credentials&client_id=$1&client_secret=$2")
    fi
    oAuthToken=$(echo $oAuthToken | /usr/bin/sed "s/{.*\"access_token\":\"\([^\"]*\).*}/\1/g")
    if [[ "$oAuthToken" == '{"error":"invalid_client"}' || -z "$oAuthToken" ]]; then
        #api failed
        log_error "Failed to retrieve oAuth Token"
        echo "no"
    fi
    echo "$oAuthToken"
    log_info "Oauth token retrieved"
}

# MDM command via api
# $1 - InstallAction, $2 - ProductKey or ProductVersion, $3 - productKey/version data
mdmCommand() {
    # custom MDM command API using UUID instead of serial
    if [ -n "$proxy" ]; then
        response=$(/usr/bin/curl -x $proxy "$apiURL/api/mdm/devices/commands?command=CustomMdmCommand&searchby=Udid&id=$uuid" \
            -X POST \
            -H "Authorization: Bearer $authToken" \
            -H "Accept: application/json;version=2" \
            -H "Content-Type: application/json" \
            -d '{"CommandXML" : "<dict><key>RequestType</key><string>ScheduleOSUpdate</string><key>Updates</key><array><dict><key>InstallAction</key><string>'$1'</string><key>'$2'</key><string>'$3'</string></dict></array></dict>"}')
    else
        response=$(/usr/bin/curl "$apiURL/api/mdm/devices/commands?command=CustomMdmCommand&searchby=Udid&id=$uuid" \
            -X POST \
            -H "Authorization: Bearer $authToken" \
            -H "Accept: application/json;version=2" \
            -H "Content-Type: application/json" \
            -d '{"CommandXML" : "<dict><key>RequestType</key><string>ScheduleOSUpdate</string><key>Updates</key><array><dict><key>InstallAction</key><string>'$1'</string><key>'$2'</key><string>'$3'</string></dict></array></dict>"}')
    fi

    log_info "API call sent - udid: $uuid, action: $1, type: $2, value: $3"
    log_info "API Response: $response"
    if [[ -n "$response" ]]; then
        #api failed
        log_error "Failed to send MDM command via API"
        log_error "API Response: $response"
        echo "no"
        return
    fi
    log_info "command sent"
    echo ""
}

mdmCommandSerial() {
    # custom MDM command API using UUID instead of serial
    if [ -n "$proxy" ]; then
        response=$(/usr/bin/curl -x $proxy "$apiURL/api/mdm/devices/commands?command=CustomMdmCommand&searchby=SerialNumber&id=$serial" \
            -X POST \
            -H "Authorization: Bearer $authToken" \
            -H "Accept: application/json;version=2" \
            -H "Content-Type: application/json" \
            -d '{"CommandXML" : "<dict><key>RequestType</key><string>ScheduleOSUpdate</string><key>Updates</key><array><dict><key>InstallAction</key><string>'$1'</string><key>'$2'</key><string>'$3'</string></dict></array></dict>"}')
    else
        response=$(/usr/bin/curl "$apiURL/api/mdm/devices/commands?command=CustomMdmCommand&searchby=SerialNumber&id=$serial" \
            -X POST \
            -H "Authorization: Bearer $authToken" \
            -H "Accept: application/json;version=2" \
            -H "Content-Type: application/json" \
            -d '{"CommandXML" : "<dict><key>RequestType</key><string>ScheduleOSUpdate</string><key>Updates</key><array><dict><key>InstallAction</key><string>'$1'</string><key>'$2'</key><string>'$3'</string></dict></array></dict>"}')
    fi

    log_info "API call sent - serial: $serial, action: $1, type: $2, value: $3"
    log_info "API Response: $response"
    if [[ ! -z "$response" ]]; then
        #api failed
        echo "no"
        log_error "Failed to send MDM command via API"
        return
    fi
    echo ""
}

# installer check
dlCheck() {
    #check major or minor update
    if [[ "$1" = "major" ]]; then
        #check for installer file cooresponding to major version number
        log_info "checking for major update download"
        case $desiredMajor in
        "11")
            # Checking for Big Sur
            if [ -d "/Applications/Install macOS Big Sur.app" ]; then
              #verify version matches
              installerVersion=$(/usr/libexec/PlistBuddy -c "Print :DTPlatformVersion" "/Applications/Install macOS Big Sur.app/Contents/Info.plist")
              if [[ $(version $installerVersion) -eq $(version $desiredOS) ]]; then
                echo "yes"
              else
                log_info "update found but wrong version. deleting wrong version"
                rm -rf "/Applications/Install macOS Big Sur.app"
                echo "no"
              fi
            else echo "no"; fi

            ;;
        "12")
            # Checking for Monterey
            if [ -d "/Applications/Install macOS Monterey.app" ]; then
              #verify version matches
              installerVersion=$(/usr/libexec/PlistBuddy -c "Print :DTPlatformVersion" "/Applications/Install macOS Monterey.app/Contents/Info.plist")
              if [[ $(version $installerVersion) -eq $(version $desiredOS) ]]; then
                echo "yes"
              else
                log_info "update found but wrong version. deleting wrong version"
                rm -rf "/Applications/Install macOS Monterey.app"
                echo "no"
              fi
            else echo "no"; fi

            ;;
        "13")
            # Checking for Ventura
            if [ -d "/Applications/Install macOS Ventura.app" ]; then
              #verify version matches
              installerVersion=$(/usr/libexec/PlistBuddy -c "Print :DTPlatformVersion" "/Applications/Install macOS Ventura.app/Contents/Info.plist")
              if [[ $(version $installerVersion) -eq $(version $desiredOS) ]]; then
                echo "yes"
              else
                log_info "update found but wrong version. deleting wrong version"
                rm -rf "/Applications/Install macOS Ventura.app"
                echo "no"
              fi
            else echo "no"; fi

            ;;
        "14")
            # Checking for Sonoma
            if [ -d "/Applications/Install macOS Sonoma.app" ]; then
              #verify version matches
              installerVersion=$(/usr/libexec/PlistBuddy -c "Print :DTPlatformVersion" "/Applications/Install macOS Sonoma.app/Contents/Info.plist")
              if [[ $(version $installerVersion) -eq $(version $desiredOS) ]]; then
                echo "yes"
              else
                log_info "update found but wrong version. deleting wrong version"
                rm -rf "/Applications/Install macOS Sonoma.app"
                echo "no"
              fi
            else echo "no"; fi

            ;;
        *)
            echo "no"
            ;;
        esac
    elif [[ "$rsrMode" == 1 ]]; then
        #find RSR download
        log_info "checking for RSR update download"
        #check directory exists
        dirCount=$(find /System/Library/AssetsV2/com_apple_MobileAsset_MacSplatSoftwareUpdate -maxdepth 1 -type d | /usr/bin/wc -l)
        if [[ "$dirCount" -gt 1 ]]; then
            #check for matching OS version
            index=1
            while [ $index -lt $dirCount ]; do
                index=$((index + 1))
                updateDir=$(find /System/Library/AssetsV2/com_apple_MobileAsset_MacSplatSoftwareUpdate -maxdepth 1 -type d | /usr/bin/awk 'NR=='$index'{print}')
                msuPlist="$updateDir/Info.plist"
                msuOSVersion=$(/usr/libexec/PlistBuddy -c "Print :MobileAssetProperties:OSVersion" "$msuPlist")
                msuRSRVersion=$(/usr/libexec/PlistBuddy -c "Print :MobileAssetProperties:ProductVersionExtra" "$msuPlist")
                if [[ $(version $msuOSVersion) -eq $(version $desiredOS) ]] && [[ "$msuRSRVersion" == "$rsrVersion" ]]; then
                    log_info "Download found"
                    echo "yes"
                    return
                fi
            done
            log_error "Download found but not correct"
            log_debug "desiredOS: $desiredOS msuOSVersion: $msuOSVersion"
            echo "no"
        else
            #download not started
            log_info "Download not found"
            log_debug "dirCount: $dirCount"
            echo "no"
        fi
    else
        #find minor update then search if downloaded
        log_info "checking for minor update download"
        #check directory exists
        dirCount=$(find /System/Library/AssetsV2/com_apple_MobileAsset_MacSoftwareUpdate -maxdepth 1 -type d | /usr/bin/wc -l)
        if [[ "$dirCount" -gt 1 ]]; then
            #check for matching OS version
            index=1
            while [ $index -lt $dirCount ]; do
                index=$((index + 1))
                updateDir=$(find /System/Library/AssetsV2/com_apple_MobileAsset_MacSoftwareUpdate -maxdepth 1 -type d | /usr/bin/awk 'NR=='$index'{print}')
                msuPlist="$updateDir/Info.plist"
                msuOSVersion=$(/usr/libexec/PlistBuddy -c "Print :MobileAssetProperties:OSVersion" "$msuPlist")
                if [[ $(version $msuOSVersion) -eq $(version $desiredOS) ]]; then
                    log_info "Download found"
                    echo "yes"
                    return
                fi
            done
            log_error "Download found but not correct"
            log_debug "desiredOS: $desiredOS msuOSVersion: $msuOSVersion"
            echo "no"
        else
            #download not started
            log_info "Download not found"
            log_debug "dirCount: $dirCount"
            echo "no"
        fi
    fi
}

# download installer
dlInstaller() {
    #check major or minor update
    if [[ "$1" = "major" ]]; then
        #download major OS Installer
        log_debug "downloading major update"
        log_debug "currentMajor: $currentMajor"
        if [[ "$currentMajor" -ge "12" ]]; then
            #use productVersion
            log_info "mdmCommand Default ProductVersion $desiredOS"
            mdmCommand "Default" "ProductVersion" "$desiredOS"
        else
            #use productKey
            log_info "mdmCommand Default ProductKey $desiredProductKey"
            mdmCommand "Default" "ProductKey" "$desiredProductKey"
        fi
    else
        #check if need to use ProductKey or ProductVersion (macOS 12+) in MDM command
        log_debug "downloading $1 update"
        log_debug "currentMajor: $currentMajor"
        if [[ "$currentMajor" -ge "12" ]] && [[ "$rsrMode" == 0 ]]; then
            #use productVersion
            log_info "mdmCommand DownloadOnly ProductVersion $desiredOS"
            mdmCommand "DownloadOnly" "ProductVersion" "$desiredOS"
        else
            #use productKey
            log_info "mdmCommand DownloadOnly ProductKey $desiredProductKey"
            mdmCommand "DownloadOnly" "ProductKey" "$desiredProductKey"
        fi
    fi
    #echo "Downloading"
}

# prompt user
userPrompt() {
    #collect info from settings plist
    title=$(/usr/libexec/PlistBuddy -c "Print :messageTitle" "$managedPlist")
    message=$(/usr/libexec/PlistBuddy -c "Print :messageBody" "$managedPlist")
    icon=$(/usr/libexec/PlistBuddy -c "Print :messageIcon" "$managedPlist")
    promptTimer=$(/usr/libexec/PlistBuddy -c "Print :promptTimer" "$managedPlist")
    deferrals=$((maxDeferrals - deferralCount))
    log_debug "title: $title message: $message icon: $icon promptTimer: $promptTimer deferrals: $deferrals"
    # $1 will tell us if deferral button should be present
    if [[ "$1" = "deferral" ]]; then
        #prompt user with buttons and deferral info
        prompt=$(/bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$message \n\nYou have $deferrals deferrals remaining before the update will automatically commence.\" with title \"$title\" with icon POSIX file \"$icon\" buttons {\"Defer\", \"$buttonLabel\"} default button 2 giving up after $promptTimer")
    elif [[ "$1" = "deadline" ]]; then
      #prompt user with buttons and deadline info
      begin=$(/usr/libexec/PlistBuddy -c "Print :startDate" "$counterFile")
      dlDate=$(date -j -f "%a %b %e %H:%M:%S %Z %Y" -v+"$maxDays"d "$begin" +'%B %d, %Y')
      time=$(/usr/libexec/PlistBuddy -c "Print :deadlineTime" "$counterFile")
      dlHour=$(echo "$time" | cut -f1 -d ":")
      dlMinute=$(echo "$time" | cut -f2 -d ":")
      if [ "$dlHour" -lt "12" ]; then
          #do nothing
          #dlHour=$(($dlHour-0))
          time="$dlHour:$dlMinute AM"
      else
          #convert to 12 hr
          dlHour=$(($dlHour-12))
          if [ $dlHour -eq 0 ]; then dlHour=12; fi
          time="$dlHour:$dlMinute PM"
      fi
      prompt=$(/bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$message \n\nIf not previously completed, the update will automatically commence on $dlDate at $time.\" with title \"$title\" with icon POSIX file \"$icon\" buttons {\"Snooze\", \"$buttonLabel\"} default button 2 giving up after $promptTimer")
    else
        #prompt user with no buttons - message that upgrade is commencing, save all work and close all apps
        prompt=$(/bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$message \n\nThe upgrade will begin momentarily. Please save any work and close all applications.\" with title \"$title\" with icon POSIX file \"$icon\" buttons {\"$buttonLabel\"} default button 1 giving up after 300")
    fi
    log_debug "prompt: $prompt"
    echo "$prompt"
}

# secondary prompt to inform user of major update install progress
installStatus() {
    #create script and call it to notify user update is installing and reboot coming
    /bin/cat <<"EOT" >installStatus.sh
  #!/bin/bash
  #notify user that migration is underway - intelligent hub is downloading and installing
  alertText="macOS Update Installation In Progress..."
  alertMessage="The macOS Update is now being prepared. Please save any work and close all applications as your Mac will be rebooted as soon as it has completed installation."
  currentUser=$(stat -f%Su /dev/console)
  currentUID=$(id -u "$currentUser")
  installLog="/private/var/log/install.log"
  #/bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$alertMessage\" with title \"$alertText\" with icon stop buttons {\"OK\"}" &
  updateProgress=$(/usr/bin/grep -e "Progress: phase:PREPARING_UPDATE stalled:NO portionComplete:" "$installLog" | /usr/bin/awk 'END{print substr($8,19,2)}')
  updatePrepDone=$(/usr/bin/grep -e "Progress: phase:COMPLETED stalled:NO portionComplete:1.000000" "$installLog")
  #report update prep %
  count=0
  while [ -z "$updatePrepDone" ]
  do
    updateProgress=$(/usr/bin/grep -e "Progress: phase:PREPARING_UPDATE stalled:NO portionComplete:" "$installLog" | /usr/bin/awk 'END{print substr($8,19,2)}')
    updatePrepDone=$(/usr/bin/grep -e "Progress: phase:COMPLETED stalled:NO portionComplete:1.000000" "$installLog")
    #display progress
    interval=$(( count % 180 ))
    if [[ ! -z "$updateProgress" && "$interval" -eq 0 ]]; then
      alertText="macOS Update Installation In Progress..."
      alertMessage="The macOS Update is now installing. Please save any work and close all applications as your Mac will be rebooted as soon as it has completed installation.\n\n Percentage Complete: $updateProgress%"
      /bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$alertMessage\" with title \"$alertText\" with icon stop buttons {\"OK\"} giving up after 60" &
    fi
    #wait - timeout after 60 minutes
    if [[ $count -eq 3600 ]]; then
      echo "update failed to prep"
      alertText="macOS Update Failed"
      alertMessage="The macOS Update failed to install. The installation will be retried at a later time. Please reach out to your IT helpdesk if you have any questions."
      /bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$alertMessage\" with title \"$alertText\" with icon stop buttons {\"OK\"}" &
      exit 0
    fi
    count=$((count+1))
    sleep 1
  done
  #done - reboot
  count=0
  updateSuccess=$(/usr/bin/grep -e "Apply succeeded, proceeding with reboot" "$installLog")
  while [ -z "$updateSuccess" ]
  do
    updateSuccess=$(/usr/bin/grep -e "Apply succeeded, proceeding with reboot" "$installLog")
    #wait - timeout after 10 minutes
    if [[ $count -eq 600 ]]; then
      echo "update failed to prep"
      alertText="macOS Update Failed"
      alertMessage="The macOS Update failed to install. The installation will be retried at a later time. Please reach out to your IT helpdesk if you have any questions."
      /bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$alertMessage\" with title \"$alertText\" with icon stop buttons {\"OK\"}" &
      exit 0
    fi
    count=$((count+1))
    sleep 1
  done
  alertText="macOS Update Installation In Progress..."
  alertMessage="The macOS Update is now installed. Your device will now reboot."
  /bin/launchctl asuser "$currentUID" sudo -iu "$currentUser" /usr/bin/osascript -e "display dialog \"$alertMessage\" with title \"$alertText\" with icon stop buttons {\"OK\"}" &
EOT

    (set -m; /bin/bash installStatus.sh &)
}

# install OS update
installUpdate() {
    #check major or minor update
    if [[ "$1" = "major" ]]; then
        #install major update
        #check if need to use ProductKey or ProductVersion (macOS 12+) in MDM command
        log_info "installUpdate: major currentMajor: $currentMajor"
        if ge "$currentMajor" "12"; then
            #use productVersion
            log_info "mdmCommand InstallASAP ProductVersion $desiredOS"
            mdmResponse=$(mdmCommand "InstallASAP" "ProductVersion" "$desiredOS")
        else
            #use productKey - check intel vs apple silicon as well
            cpuType=$(/usr/sbin/sysctl -n machdep.cpu.brand_string)
            if [[ "$cpuType" =~ ^Intel/ ]]; then
                #intel - use startosinstall
                log_info "Triggering update with startosinstall"
                log_debug "cpuType: $cpuType desiredMajor: $desiredMajor"
                case $desiredMajor in
                "11")
                    log_info "running startosinstall for Big Sur"
                    /Applications/Install\ macOS\ Big\ Sur.app/Contents/Resources/startosinstall --agreetolicense --nointeraction --forcequitapps &
                    ;;
                "12")
                    log_info "running startosinstall for Monterey"
                    /Applications/Install\ macOS\ Monterey.app/Contents/Resources/startosinstall --agreetolicense --nointeraction --forcequitapps &
                    ;;
                "13")
                    log_info "running startosinstall for Ventura"
                    /Applications/Install\ macOS\ Ventura.app/Contents/Resources/startosinstall --agreetolicense --nointeraction --forcequitapps &
                    ;;
                "14")
                    log_info "running startosinstall for Sonoma"
                    /Applications/Install\ macOS\ Sonoma.app/Contents/Resources/startosinstall --agreetolicense --nointeraction --forcequitapps &
                    ;;
                *)
                    log_error "cpuType: $cpuType desiredMajor: $desiredMajor  Unsupported macOS version $currentOS"
                    echo "unknown major version"
                    ;;
                esac
            else
                #apple silicon - use MDM commands
                log_debug "cpuType: $cpuType desiredMajor: $desiredMajor chose Apple Silicon MDM command"
                desiredProductKey=$(getProductKey "$updateType")
                log_info "mdmCommand InstallASAP ProductKey $desiredProductKey"
                mdmResponse=$(mdmCommand "InstallASAP" "ProductKey" "$desiredProductKey")
            fi
        fi
    else
        #install minor update
        #check if need to use ProductKey or ProductVersion (macOS 12+) in MDM command
        log_debug "installUpdate: minor currentMajor: $currentMajor"
        if [[ "$currentMajor" -ge "12" ]] && [[ "$rsrMode" == 0 ]]; then
            #use productVersion
            log_info "mdmCommand InstallForceRestart ProductVersion $desiredOS"
            mdmResponse=$(mdmCommand "InstallForceRestart" "ProductVersion" "$desiredOS")
            #sleep 1 minute and InstallASAP if update not already started
            sleep 60
            log_info "mdmCommand InstallASAP ProductVersion $desiredOS"
            mdmResponse=$(mdmCommand "InstallASAP" "ProductVersion" "$desiredOS")
        else
            #use productKey
            log_info "mdmCommand InstallForceRestart ProductKey $desiredProductKey"
            mdmResponse=$(mdmCommand "InstallForceRestart" "ProductKey" "$desiredProductKey")
            #sleep 1 minute and InstallASAP if update not already started
            sleep 60
            log_info "mdmCommand InstallASAP ProductKey $desiredProductKey"
            mdmResponse=$(mdmCommand "InstallASAP" "ProductKey" "$desiredProductKey")
        fi
    fi
    if [[ -n "$mdmResponse" ]]; then
        log_error "Error sending mdm command - mdmResponse: $mdmResponse"
        gatherLogs
        exit 0
    else
        (set -m; /usr/bin/caffeinate -t 7200 &) # prevent sleep while installing update
        log_info "installUpdate: update command sent successfully"
        echo "Command Sent"
    fi
}

### main code
#Setup Logging
log_level INFO
log_file_name "$logLocation"
log_to_screen false

log_info "===== Launching macOS Updater Utility $(date)============"
#log "===== Launching macOS Updater Utility ====="
log_info "  --- Revision 12.1 ---  "


#Setup ManagePlist
managedPlistFile="com.macOSupdater.settings.plist"
managedPlistPath="/Library/Managed Preferences/"
managedPlist="$managedPlistPath$managedPlistFile"
checkLocation="$managedPlistPath$currentUser/$managedPlistFile"
checkAirWatchLocation="/Library/Application Support/AirWatch/Data/profiles.plist"
if [[ -a "$managedPlist" ]]; then
    log_info "Managed Preferences file found at $managedPlist"
elif [[ -a "$checkLocation" ]]; then
    log_info "Managed Preferences file found in $checkLocation"
    managedPlist="$checkLocation"
elif [[ -a "$checkAirWatchLocation" ]]; then
    log_info "Managed Preferences file found in $checkAirWatchLocation"
    managedPlist="/tmp/com.macOSupdater.settings.plist"
    for ((i=0; i<8; i++)); do
        profile_items_number=$(plutil -extract _computerlevel.$i.ProfileItems json -o - "${checkAirWatchLocation}")
        search_string="desiredOSversion"
        if [[ "$profile_items_number" =~ $search_string ]]; then
            for ((j=0; j<8; j++)); do
                profile_payload_content_list=$(plutil -extract _computerlevel.$i.ProfileItems.$j.PayloadContent json -o - "${checkAirWatchLocation}")
                testValue="desiredOSversion"
                if [[ "$profile_payload_content_list" =~ $testValue ]]; then
                    (plutil -extract _computerlevel.$i.ProfileItems.$j.PayloadContent xml1 -o "${managedPlist}" "${checkAirWatchLocation}")
                    j=8
                    i=8
                fi
            done
        fi
    done
else
    log_error "Managed Preferences file not found at either of the standard locations: $managedPlist or $checkLocation or $checkAirWatchLocation"
    log_error "Please check the location of the Managed Preferences file and update the script if necessary"
fi


#check if user is logged in
if [[ "$currentUser" = "root" ]]; then exit 0; fi
log_info "$currentUser is logged in"

#check if settings profile is Installed
if [ ! -f "$managedPlist" ]; then
    #clean up counter file and Exit
    /bin/rm -f "$counterFile"
    log_info "config profile not installed, exiting....."
    gatherLogs
    exit 0
fi

#check which mode is enabled - latest, RSR or none (normal)
rsrMode=0
latestMode=0
deadlineMode=0
rsrVersion=""
desiredOS=$(/usr/libexec/PlistBuddy -c "Print :desiredOSversion" "$managedPlist")
if [[ "$desiredOS" == "latest" ]]; then
  latestMode=1
  log_info "latest mode enabled - retrieving latest minor version release"
  #get latest version
  /bin/mkdir -p "/private/var/macOSupdater/"
  /usr/bin/curl "https://gdmf.apple.com/v2/pmv" -o "/private/var/macOSupdater/appleOS.json"
  /usr/bin/plutil -convert xml1 "/private/var/macOSupdater/appleOS.json" -o "/private/var/macOSupdater/OS.plist"
  currentMajor=$(echo $currentOS | /usr/bin/cut -f1 -d ".")
  desiredOS=$(/usr/libexec/PlistBuddy -c "Print :PublicAssetSets:macOS" "/private/var/macOSupdater/OS.plist" | /usr/bin/grep "ProductVersion = $currentMajor" | /usr/bin/awk '{print $3}')
  log_info "latest mode - desiredOS set to: $desiredOS"
#check if RSR is being requested
elif [[ "${desiredOS: -1}" == ")" ]]; then
  rsrVersion=$(echo "$desiredOS" | cut -f2 -d " ")
  desiredOS=$(echo "$desiredOS" | cut -f1 -d " ")
  log_info "RSR Mode requested - RSR requested: $rsrVersion desiredOS: $desiredOS"
  log_info "Need to ensure device is on desiredOS before applying RSR"
fi

#check if mac is already on desired version or higher
if ge "$(version "$currentOS")" "$(version "$desiredOS")"; then
    #check if RSR is requested
    if [[ ! -z "$rsrVersion" ]]; then
      #verify if RSR is applied
      log_info "checking if RSR requested needs to be applied"
      currentRSR=$(sw_vers -ProductVersionExtra)
      log_info "current RSR: $currentRSR"
      if [[ "$currentRSR" == "$rsrVersion" ]]; then
        #clean up counter file and Exit
        rm -f "$counterFile"
        log_info "device is up to date, exiting....."
        gatherLogs
        exit 0
      fi
      log_info "need to apply RSR - $rsrVersion"
      rsrMode=1
    #check if RSR available if using latest
    elif [[ "$latestMode" == 1 ]]; then
      #find most recent rsrVersion if there is one, if not dont set rsrMode
      log_info "device up to date - checking if RSR available"
      rsrVersion=$(/usr/libexec/PlistBuddy -c "Print :PublicRapidSecurityResponses:macOS" "/private/var/macOSupdater/OS.plist" 2>/dev/null | /usr/bin/awk '/ProductVersion = '$currentMajor'/{ getline; print $3}' || :)
      if [[ ! -z "$rsrVersion" ]]; then
        log_info "RSR available - check if needs to be applied. RSR Version: $rsrVersion"
        currentRSR=$(sw_vers -ProductVersionExtra)
        log_info "current RSR: $currentRSR"
        if [[ "$currentRSR" == "$rsrVersion" ]]; then
          #clean up counter file and Exit
          rm -f "$counterFile"
          log_info "device is up to date, exiting....."
          gatherLogs
          exit 0
        fi
        log_info "need to apply RSR - $rsrVersion"
        rsrMode=1
      fi
    else
      #clean up counter file and Exit
      rm -f "$counterFile"
      log_info "device is up to date, exiting....."
      gatherLogs
      exit 0
    fi
fi
log_info "upgrade needed - currentOS: $currentOS : desiredOS: $desiredOS"

#check if properties file has been created, if not create it
if [ ! -f "$counterFile" ]; then
    /usr/bin/defaults write "$counterFile" deferralCount -int 0
    /usr/bin/defaults write "$counterFile" startDate -date "$(date)"
fi

#check if using deferrals or deadline date
maxDays=$(/usr/libexec/PlistBuddy -c "Print :maxDays" "$managedPlist" 2>/dev/null || :)
if [ "$maxDays" = "" ]; then
  log_info "deferral mode active"
  deferralCount=$(/usr/libexec/PlistBuddy -c "Print :deferralCount" "$counterFile")
  maxDeferrals=$(/usr/libexec/PlistBuddy -c "Print :maxDeferrals" "$managedPlist")
else
  log_info "deadline mode active"
  deadlineMode=1
  begin=$(/usr/libexec/PlistBuddy -c "Print :startDate" "$counterFile" 2>/dev/null || :)
  #verify startDate
  if [ "$begin" = "" ]; then
    /usr/bin/defaults write "$counterFile" startDate -date "$(date)"
    begin=$(/usr/libexec/PlistBuddy -c "Print :startDate" "$counterFile")
  fi
  startDate=$(date -j -f "%a %b %e %H:%M:%S %Z %Y" "$begin" +'%m/%d/%Y')
  deadlineDate=$(date -j -v+"$maxDays"d -f "%m/%d/%Y" "$startDate" +'%m/%d/%Y')
  deadlineTime=$(/usr/libexec/PlistBuddy -c "Print :deadlineTime" "$managedPlist" 2>/dev/null || :)
  if [ "$deadlineTime" = "" ]; then deadlineTime="06:00"; fi
  /usr/bin/defaults write "$counterFile" deadlineTime -string "$deadlineTime"
  combine="$deadlineDate $deadlineTime"
  dlCombine=$(date -j -f "%m/%d/%Y %H:%M" "$combine" +'%s')
fi
log_info "counter present"

#check if major update or minor
currentMajor=$(echo $currentOS | /usr/bin/cut -f1 -d ".")
desiredMajor=$(echo $desiredOS | /usr/bin/cut -f1 -d ".")
if [ $currentMajor -lt $desiredMajor ]; then updateType="major"; else updateType="minor"; fi
log_info "$updateType update requested"

#grab desired product key if needed - currentOS < 12.0 OR RSR Mode
#check major or minor
if le "$currentMajor" "11" || [[ "$rsrMode" == 1 ]]; then
    desiredProductKey=$(getProductKey "$updateType")
    log_info "ProductKey: $desiredProductKey"

    #check if null
    if [ "$desiredProductKey" = "" ]; then
        log_info "No product key found, exiting....."
        gatherLogs
        exit 0
    fi
fi

#grab proxy info
proxy=$(/usr/libexec/PlistBuddy -c "Print :proxy" "$managedPlist" 2>/dev/null || :)

#grab API info
log_info "retrieving oauth token"
authToken=$(getToken $clientID $clientSec)
if [[ "$authToken" == "no" ]]; then
    log_info "oAuth token not found - check API variables, exiting....."
    gatherLogs
    exit 0
fi

#check if update has downloaded, if not trigger download and exit
downloadCheck=$(dlCheck "$updateType")
log_info "downloadCheck: $downloadCheck"
if [[ "$downloadCheck" = "no" ]]; then
    #differentiate between major and minor
    if [[ "$updateType" = "major" ]]; then
        #download major OS Installer
        (set -m; /usr/sbin/softwareupdate --fetch-full-installer --full-installer-version "$desiredOS" &)
        if [ "$desiredMajor" -ge "13" ] && [ "$currentOS" != "12.6.8" ]; then
            response=$(dlInstaller "$updateType")
            if [[ "$response" == "no" ]]; then
                log_info "API command to download installer failed, exiting....."
            else
                log_info "major update installer download started via MDM command"
            fi
        fi
        log_info "major update installer download started, exiting....."
    else
        response=$(dlInstaller "$updateType")
        if [[ "$response" == "no" ]]; then
            log_info "API command to download installer failed, exiting....."
        else
            log_info "minor update installer download started, exiting....."
        fi
    fi
    gatherLogs
    exit 0
fi
log_info "installer downloaded"

if [[ "$deadlineMode" == 1 ]]; then
  log_info "deadline mode info:"
  log_info "enforcement start date: $startDate"
  log_info "maxDays: $maxDays"
else
  log_info "deferral mode info:"
  log_info "deferrals: $deferralCount"
  log_info "maxDeferrals: $maxDeferrals"
fi

#check if user is active - if using deferrals
if [[ "$deadlineMode" == 0 ]]; then
  userStatus=$(/usr/bin/pmset -g useractivity | /usr/bin/grep "Level =" | /usr/bin/awk '{print $3}' | /usr/bin/tr -d "'")
  log_info "User status: $userStatus"
  if [[ ! "$userStatus" = "PresentActive" ]]; then
      log_info "user is not active so not proceeding to prompt, exiting....."
      gatherLogs
      exit 0
  fi
fi

#prompt user to upgrade
buttonLabel=$(/usr/libexec/PlistBuddy -c "Print :buttonLabel" "$managedPlist" 2>/dev/null || :)
if [ "$buttonLabel" = "" ]; then buttonLabel="Upgrade"; fi
echo "label - $buttonLabel"

#check if using deadlineMode or deferrals
if [[ "$deadlineMode" == 1 ]]; then
  #verify dayCount
  currentDate=$(date +'%s')
  if [[ $currentDate -lt $dlCombine ]]; then
      #prompt user to upgrade with deadline option
      log_info "prompting user with deferral - deadline"
      userReturn=$(userPrompt "deadline")
      log_info "userReturn: $userReturn"
      #check user response
      if [ "$userReturn" = "button returned:$buttonLabel, gave up:false" ]; then
          #trigger update and exit
          log_info "installing update"
          installUpdate "$updateType"
          #trigger script to notify user that upgrade is installing and reboot is imminent
          log_info "triggering notification script"
          installStatus
      else
          #user did not accept - snooze
          log_info "user snoozed or timeout expired"
      fi
  else
      #force update
      #prompt user that upgrade will take place momentarily - close out of all programs, save work, etc.
      log_info "prompting user without deferral"
      userPrompt "force"
      #trigger update
      log_info "installing update"
      installUpdate "$updateType"
      #trigger script to notify user that upgrade is installing and reboot is imminent
      log_info "triggering notification script"
      installStatus
  fi
else # deferal mode
  #check if user has deferrals remaining
  if [[ $deferralCount -lt $maxDeferrals ]]; then
      #prompt user to upgrade with deferral option
      log_info "prompting user with deferral"
      userReturn=$(userPrompt "deferral")
      log_info "userReturn: $userReturn"
      #check user response
      if [ "$userReturn" = "button returned:$buttonLabel, gave up:false" ]; then
          #trigger update and exit
          log_info "installing update"
          installUpdate "$updateType"
          #trigger script to notify user that upgrade is installing and reboot is imminent
          log_info "triggering notification script"
          installStatus
      else
          #increase deferral count and exit
          log_info "user deferred"
          deferralCount=$((deferralCount + 1))
          /usr/bin/defaults write "$counterFile" deferralCount -int $deferralCount
      fi
  else
      #prompt user that upgrade will take place momentarily - close out of all programs, save work, etc.
      log_info "prompting user without deferral"
      userPrompt "force"
      #trigger update
      log_info "installing update"
      installUpdate "$updateType"
      #trigger script to notify user that upgrade is installing and reboot is imminent
      log_info "triggering notification script"
      installStatus
  fi
fi

log_info ">>>>> Exiting macOS Updater Utility <<<<<"
gatherLogs
exit 0

###EOF###macOSupdater.sh
