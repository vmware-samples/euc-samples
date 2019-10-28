#!/bin/sh
# Copyright 2013-2015 Crittercism, Inc. All rights reserved.
#
# Usage:
#   * (These instructions assume you have dragged the "CrittercismSDK" folder
#     into your project in XCode)
#   * In the project editor, select your target.
#   * Click "Build Phases" at the top of the project editor.
#   * Click "Add Build Phase" in the lower right corner.
#   * Choose "Add Run Script."
#   * Paste the following script into the dark text box. You will have to
#     uncomment the lines (remove the #s) of course.
#   * Go to https://app.crittercism.com/developers/app-settings/<YOUR_APP_ID>
#     to obtain an API key
#
# --- API_KEY SCRIPT BEGINS ON NEXT LINE, COPY AND EDIT FROM THERE ---
# APP_ID="<YOUR_APP_ID>"
# API_KEY="<YOUR_API_KEY>"
# source ${SRCROOT}/CrittercismSDK/dsym_upload.sh
# --- END OF SCRIPT ---
#
# --- OAUTH2 SCRIPT BEGINS ON NEXT LINE, COPY AND EDIT FROM THERE ---
# APP_ID="<YOUR_APP_ID>"
# OAUTH2="<OAUTH2 TOKEN>"
# source ${SRCROOT}/CrittercismSDK/dsym_upload.sh
# --- END OF SCRIPT ---
#

################################################################################
# Advanced Settings
#
# You can over-ride these directly in XCode in your Run Script Build Phase, or
# change the defaults below.

# Should simulator builds cause symbols to be uploaded?
UPLOAD_SIMULATOR_SYMBOLS=${UPLOAD_SIMULATOR_SYMBOLS:=1}

# This setting determines whether or not your build will fail if the dSYM was
# not uploaded properly to Crittercism's servers.
#
# You may wish to change this setting if you are building without internet
# access, or otherwise are having difficulty connecting to Crittercism's
# servers.
REQUIRE_UPLOAD_SUCCESS=${REQUIRE_UPLOAD_SUCCESS:=1}

################################################################################
# You should not need to edit anything past this point.

#
#  Verbose mode prints extra messages via this function
#
function verbose() {
  message="$1"
  if $VERBOSE; then
    echo "$message"
  fi
}

#
#  cleanup function removes TMP directory
#
TMP=""
function cleanup() {
  # Initially, TMP="" and MKTEMP_EXE hasn't been called yet.
  # Farther into the script, MKTEMP_EXE is defined and TMP
  # directory may be created.  Remove TMP directory if we
  # created TMP.
  if [ "$TMP" != "" ] && [ -d "$TMP" ]; then
    rm -rf "$TMP"
  fi
  verbose "cleanup completed"
}

#
#  exitWithMessageAndCode function prints message and exits
#
function exitWithMessageAndCode() {
  message="$1"
  echo "$message"
  cleanup
  exit ${2}
}

#
#  Check requirements are existing executable files
#
function check_exec() {
  path="$1"
  if [[ ! -f "$path" ]]; then
    fail "File '$path' is not found. ABORTING."
  elif [[ ! -x "$path" ]]; then
    fail "File '$path' is not executable. ABORTING."
  fi
}

function setup_for_macosx() {
  MKTEMP_EXE="/usr/bin/mktemp"
  check_exec "$MKTEMP_EXE"
  PLISTBUDDY_EXE="/usr/libexec/PlistBuddy"
  check_exec "$PLISTBUDDY_EXE"
  RM_EXE="/bin/rm"
  check_exec "$RM_EXE"
  ZIP_EXE="/usr/bin/zip"
  check_exec "$ZIP_EXE"
}  #  End of function  setup_for_macosx.

function exit_unsupported_os() {
  fail "ERROR: Your OS [$1] is not supported - use Mac OSX";
}  #  End of function  exit_unsupported_os.

#
#  main():
#
PROG_NAME=`basename $0`
UNAME=`uname -s`
case "$UNAME" in
  Darwin*)  setup_for_macosx        ;;
  *)     exit_unsupported_os "$UNAME"  ;;
esac

################################################################
# Parsing the command line.
################################################################

function terse_usage() {
  if [ $# -gt 0 ]; then
    echo $@
  fi

  echo "     ${PROG_NAME} -h"
  echo "     ${PROG_NAME} [-i appId] [-k apiKey] [-v] YourApp.dSYM"
  echo "     ${PROG_NAME} [-i appId] [-o oauth2] [-v] YourApp.dSYM"
}

function usage() {
  echo
  echo "NAME"
  echo "     ${PROG_NAME} -- Uploads a *.dSYM to CRITTERCISM.COM ."
  echo
  echo "SYNOPSIS"
  terse_usage
  echo
  echo "DESCRIPTION"
  echo "     The ${PROG_NAME} script is used to upload an iOS *.dSYM created by Xcode IDE"
  echo "     when Xcode builds an iOS app or, later on, upload an iOS *.dSYM"
  echo "     retrieved via the Xcode Organizer 'Download dSYMS...' button."
  echo
  echo "OPTIONS"
  echo "     The options are as follows:"
  echo "     -i      appId.  The App Id is a 24 or 40 digit character string."
  echo "             Obtain your App Id from Crittercism’s 'New App Registration' page:"
  echo "             North America (https://app.crittercism.com/developers/register ),"
  echo "             Europe (https://app.eu.crittercism.com/developers/register)."
  echo "             See 'Crittercism Quickstart' http://docs.crittercism.com/quickstart.html ."
  echo "             (apiKey defaults to value of environment variable APP_ID)"
  echo "     -k      apiKey.  Obtain an API_KEY from the 'Upload dSYMs' tab of the"
  echo "             'App Settings' area of the Crittercism portal for managing your app."
  echo "             (apiKey defaults to value of environment variable API_KEY)"
  echo "     -o      oauth2.  Obtain an OAuth2 token by following the instructions at"
  echo "             http://docs.crittercism.com/ios/ios.html#installing-the-ios-sdk ."
  echo "             (oauth2 defaults to value of environment variable OAUTH2)"
  echo "     -h      Help.  Print usage information."
  echo "     -v      Verbose.  Print extra script information to assist diagnosis of any issues."
  echo
  echo "API_KEY EXAMPLES"
  echo "     To upload a *.dSYM, using an interactive interface:"
  echo "             export APP_ID=\"12e08aeabddd3f0e009c406f\""
  echo "             export API_KEY=\"38263980d53vf9f17xe81ffx28beef2b\""
  echo "             sh dsym_upload.sh -v YourApp.dSYM"
  echo "     To upload a *.dSYM, using an Xcode build phase run script:"
  echo "             APP_ID=\"12e08aeabddd3f0e009c406f\""
  echo "             API_KEY=\"38263980d53vf9f17xe81ffx28beef2b\""
  echo "             source ${SRCROOT}/CrittercismSDK/dsym_upload.sh"
  echo ""
  echo "OAUTH2 EXAMPLES"
  echo "     To upload a *.dSYM, using an interactive interface:"
  echo "             export APP_ID=\"12e08aeabddd3f0e009c406f\""
  echo "             export OAUTH2=\"38263980d53vf9f17xe81ffx28beef2b\""
  echo "             sh dsym_upload.sh -v YourApp.dSYM"
  echo "     To upload a *.dSYM, using an Xcode build phase run script:"
  echo "             APP_ID=\"12e08aeabddd3f0e009c406f\""
  echo "             OAUTH2=\"38263980d53vf9f17xe81ffx28beef2b\""
  echo "             source ${SRCROOT}/CrittercismSDK/dsym_upload.sh"
}

if [ $# -eq 1 ] && [ $1 = "-h" ]; then
  usage
  exit 0
fi

# NOTE: Return absolute path. Limitation: Doesn't resolve symlinks,
# but is step forward.
realpath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

DSYM_SRC=${DSYM_SRC:=""}
APP_ID=${APP_ID:=""}
API_KEY=${API_KEY:=""}
OAUTH2=${OAUTH2:=""}
VERBOSE=false

while getopts i:k:o:hv opt; do
  case $opt in
    i)
      APP_ID="$OPTARG"
      ;;
    k)
      API_KEY="$OPTARG"
      ;;
    o)
      OAUTH2="$OPTARG"
      ;;
    h)
      usage
      exit 0
      ;;
    v)
      VERBOSE=true
      ;;
  esac
done

if [ $OPTIND = $# ]; then
  DSYM_SRC=${@:$OPTIND:1}
fi

verbose "DSYM_SRC == ${DSYM_SRC}"
verbose "APP_ID == ${APP_ID}"
verbose "API_KEY == ${API_KEY}"
verbose "OAUTH2 == ${OAUTH2}"

################################################################
# Acquire TMP, DSYM_ROOT, and DSYM_ZIP_FPATH
################################################################

verbose "Acquire TMP, DSYM_ROOT, and DSYM_ZIP_FPATH"

if [ ! "${DWARF_DSYM_FILE_NAME}" ]; then
  verbose "DWARF_DSYM_FILE_NAME is undefined"
  if [ ! "${DSYM_SRC}" ]; then
    verbose "DSYM_SRC is undefined"
    exitWithMessageAndCode "dSYM source not found: ${DSYM_SRC}" 1
  else
    # Assume running script inside Terminal window
    verbose "DSYM_SRC is defined"
    MKTEMP_EXE="/usr/bin/mktemp"
    TMP=`$MKTEMP_EXE -d -t crittercism`
    DSYM=`realpath "${DSYM_SRC}"`
    DSYM_FILE=`basename "${DSYM}"`
  fi
else
  # Assume running script inside Xcode IDE
  VERBOSE=true
  verbose "DWARF_DSYM_FILE_NAME is defined"

  TMP="${TARGET_TEMP_DIR}/crittercism"
  mkdir -p "${TMP}"

  DSYM_SRC="${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"
  DSYM_FILE="${DWARF_DSYM_FILE_NAME}"
  # Display build info
  BUNDLE_VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleVersion' ${INFOPLIST_FILE})
  BUNDLE_SHORT_VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' ${INFOPLIST_FILE})
  verbose "Product Name: ${PRODUCT_NAME}"
  verbose "Version: ${BUNDLE_SHORT_VERSION}"
  verbose "Build: ${BUNDLE_VERSION}"
fi
DSYM_ROOT=`echo ${DSYM_FILE} | sed -e "s/\.dSYM$//g"`
DSYM_ZIP_FPATH="${TMP}/${DSYM_ROOT}.zip"

verbose "TMP: ${TMP}"
verbose "DSYM_ROOT: ${DSYM_ROOT}"
verbose "DSYM_ZIP_FPATH: ${DSYM_ZIP_FPATH}"

################################################################
# Upload to Crittercism
################################################################

verbose "Uploading dSYM to Crittercism."
verbose ""

verbose "Crittercism App ID: ${APP_ID}"
verbose "Crittercism API key: ${API_KEY}"

# Possibly bail if this is a simulator build
if [ "$EFFECTIVE_PLATFORM_NAME" == "-iphonesimulator" ]; then
  if [ $UPLOAD_SIMULATOR_SYMBOLS -eq 0 ]; then
    exitWithMessageAndCode "skipping simulator build" 0
  fi
fi

# Check to make sure the necessary parameters are defined
if [ ! "${APP_ID}" ]; then
  exitWithMessageAndCode "err: Crittercism App ID is undefined." 1
fi

if [ "${OAUTH2}" ]; then
  API_KEY=${OAUTH2}
fi

if [ ! "${API_KEY}" ]; then
  exitWithMessageAndCode "err: Crittercism API Key is undefined." 1
fi

# Compute DSYM_UPLOAD_DOMAIN and DSYM_UPLOAD_URL based on APP_ID .
APP_ID_LENGTH=${#APP_ID}
if [ $APP_ID_LENGTH -eq 24 ]; then
  DSYM_DOMAIN="crittercism.com"
elif [ $APP_ID_LENGTH -eq 40 ]; then
  APP_ID_LOCATION=${APP_ID:32}
  US_WEST_1_PROD_DESIGNATOR="00555300"
  EU_CENTRAL_1_PROD_DESIGNATOR="00444503"
  if [ "${APP_ID_LOCATION}" == "${US_WEST_1_PROD_DESIGNATOR}" ]; then
    DSYM_DOMAIN="crittercism.com"
  elif [ "${APP_ID_LOCATION}" == "${EU_CENTRAL_1_PROD_DESIGNATOR}" ]; then
    DSYM_DOMAIN="crittercism.com"
  else
    verbose "Unexpected APP_ID_LOCATION == ${APP_ID_LOCATION}"
  fi
else
  verbose "Unexpected APP_ID_LENGTH == ${APP_ID_LENGTH}"
fi
if [ ! "${DSYM_DOMAIN}" ]; then
  # DSYM_DOMAIN didn't get defined.
  exitWithMessageAndCode "err: Invalid Crittercism App ID: ${APP_ID}" 1
fi
if [ ! "${OAUTH2}" ]; then
  # No OAUTH2 provided.  Assuming API_KEY style.
  verbose "API key provided."
  DSYM_UPLOAD_DOMAIN="app.${DSYM_DOMAIN}"
  verbose "dSym Upload Domain: ${DSYM_UPLOAD_DOMAIN}"
  DSYM_UPLOAD_URL="https://${DSYM_UPLOAD_DOMAIN}/api_beta/dsym/${APP_ID}"
  verbose "dSym Upload URL: ${DSYM_UPLOAD_URL}"
else
  verbose "OAUTH2 provided."
  DSYM_UPLOAD_DOMAIN="files.${DSYM_DOMAIN}"
  DSYM_PROCESS_SYMBOL_DOMAIN="app.${DSYM_DOMAIN}"
  verbose "dSym Upload Domain: ${DSYM_UPLOAD_DOMAIN}"
  DSYM_UPLOAD_URL="https://${DSYM_UPLOAD_DOMAIN}/api/v1/applications/${APP_ID}/symbol-uploads"
  DSYM_PROCESS_SYMBOL_URL="https://${DSYM_PROCESS_SYMBOL_DOMAIN}/v1.0/app/${APP_ID}/symbols/uploads"
  verbose "dSym Upload URL: ${DSYM_UPLOAD_URL}"
  verbose "dSym Process URL: ${DSYM_PROCESS_SYMBOL_URL}"
fi

# create dSYM .zip file
verbose "dSYM Source: ${DSYM_SRC}"
if [ ! -d "$DSYM_SRC" ]; then
  exitWithMessageAndCode "dSYM source not found: ${DSYM_SRC}" 1
fi

verbose "Compressing dSYM to ${DSYM_ZIP_FPATH} ."
(/usr/bin/zip --recurse-paths --quiet "${DSYM_ZIP_FPATH}" "${DSYM_SRC}") || exitWithMessageAndCode "err: Failed creating zip." 1
verbose ""
verbose "dSym.zip archive created."

# Upload dSYM to Crittercism
verbose "Uploading dSYM.zip to Crittercism: ${DSYM_UPLOAD_URL}"

CR_SUCCESS=1
if [ ! "${OAUTH2}" ]; then
  # No OAUTH2 provided.  Assuming API_KEY style.
  STATUS=$(/usr/bin/curl "${DSYM_UPLOAD_URL}" --write-out %{http_code} --silent --output /dev/null -F dsym=@"${DSYM_ZIP_FPATH}" -F key="${API_KEY}")
  verbose "Crittercism API server response: ${STATUS}"
  if [ $STATUS -ne 200 ]; then
    CR_SUCCESS=0
  fi
else
  # OAUTH2 provided.
  verbose "Crittercism Creating resource"
  AB="Authorization: Bearer "${API_KEY}""
  verbose $AB
  JSON_STRING=$(/usr/bin/curl -X POST "${DSYM_UPLOAD_URL}" -H "${AB}" --silent)
  RESOURCE_ID=$(echo $JSON_STRING | sed  's/^.*"resource-id":"\([^"]*\)".*$/\1/')
  RESOURCE_ID_LENGTH=${#RESOURCE_ID}
  if [ $RESOURCE_ID_LENGTH -eq 0 ]; then
    verbose "Crittercism Resource FAILED create"
    CR_SUCCESS=0
  else
    verbose "Crittercism Resource ${RESOURCE_ID} created"
  fi
  if [ $CR_SUCCESS -eq 1 ]; then
    DSYM_UPLOAD_URL=${DSYM_UPLOAD_URL}/${RESOURCE_ID}
    STATUS=$(/usr/bin/curl -X PUT "${DSYM_UPLOAD_URL}" --write-out %{http_code} --silent --output /dev/null -F name=symbolUpload -F filedata=@"${DSYM_ZIP_FPATH}" -H "${AB}")
    if [ $CR_SUCCESS -eq 1 ] && [ $STATUS -eq 202 ]; then
      verbose "Crittercism Resource ${RESOURCE_ID} Uploaded: ${STATUS}"
    else
      verbose "Crittercism Resource ${RESOURCE_ID} Uploaded: FAILED ${STATUS}"
      CR_SUCCESS=0
    fi
  fi
  if [ $CR_SUCCESS -eq 1 ]; then
    JSON="{\"uploadUuid\": \"${RESOURCE_ID}\",\"filename\":\"upload.zip\"}"
    STATUS=$(/usr/bin/curl  --write-out %{http_code} --silent --output /dev/null -X POST "${DSYM_PROCESS_SYMBOL_URL}" --silent -d "${JSON}" -H "${AB}" -H 'Content-Type: application/json')
    if [ $STATUS -eq 200 ]; then
      verbose "Crittercism Resource ${RESOURCE_ID} Processed: ${STATUS}"
    else
      verbose "Crittercism Resource ${RESOURCE_ID} Processed: FAILED ${STATUS}"
      CR_SUCCESS=0
    fi
  fi
fi

if [ $CR_SUCCESS -eq 0 ]; then
  verbose "err: dSYM.zip archive failed to upload to Crittercism."
  if [ $REQUIRE_UPLOAD_SUCCESS -eq 1 ]; then
    verbose "To ignore this server response and build succesfully add"
    verbose "REQUIRE_UPLOAD_SUCCESS=0"
    verbose "to the Run Script Build Phase invoking the dsym_upload.sh script."
    exit 1
  else
    verbose "Ignoring due to REQUIRE_UPLOAD_SUCCESS=0 ."
  fi
else
  verbose "Crittercism Upload COMPLETE"
fi

# Remove temp dSYM archive
verbose "Removing temporary dSYM.zip archive."
/bin/rm -f "${DSYM_ZIP_FPATH}"
if [ "$?" -ne 0 ]; then
  exitWithMessageAndCode "Error removing temporary dSYM.zip archive." 1
fi

verbose "Crittercism dSYM upload complete."

