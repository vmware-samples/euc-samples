#!/usr/bin/env python
# Trimmed down version of original by Moof IT
# https://github.com/moofit/public_scripts/blob/master/Google_Chrome_Setup/Google%20Chrome%20Setup%20Script.py
#
# v1.0 - 4/27/18
#
# Intended to only suppress prompts that the com.google.Chrome profile settings do not affect
# Use the profile settings to disable any additional prompts not covered here. It's beneficial
# to use the profile settings for most policy keys, because they will be managed and persistent.

import json
import os
import subprocess
import sys
from SystemConfiguration import SCDynamicStoreCopyConsoleUser

print('STARTING: Google Chrome Setup Script')

# Get current console username
username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,''][username in [u'loginwindow', None, u'']]; sys.stdout.write(username + '\n')

firstrundirectory = '/Users/' + username + '/Library/Application Support/Google/Chrome'
firstrunfile = '/Users/' + username + '/Library/Application Support/Google/Chrome/First Run'
firstruntopdirectory = '/Users/' + username + '/Library/Application Support/Google'
preferencesdirectory = '/Users/' + username + '/Library/Application Support/Google/Chrome/Default'
preferencesfile = '/Users/' + username + '/Library/Application Support/Google/Chrome/Default/Preferences'
runoncefile = '/Users/' + username + '/Library/Application Support/Google/Chrome/Default/PreferencesSetOnce'

# First Run file creation ########################

# Check if first run directory exists and create it if needed
if not os.path.exists(firstrundirectory):
    os.makedirs(firstrundirectory)

# Try and create the first run file
try:
    open(firstrunfile, 'a').close()
except:
    print('Failed to create first run file')
    sys.exit(1)

# Fix any permissions with this bit
try:
    subprocess.call(['chown', '-R', username, firstruntopdirectory])
except:
    print('Failed to permission the first run file directory')
    sys.exit(1)

# Preference file creation ########################

# Create the Preference file directory
if not os.path.exists(preferencesdirectory):
    try:
        os.makedirs(preferencesdirectory)
    except:
        print('Failed to create User\'s Preference file directory')
        sys.exit(1)

if os.path.isfile(preferencesfile):
	if os.path.isfile(runoncefile):
		print('Preference file exists and has been updated once already')
		sys.exit(0)
else:
    try:
        open(preferencesfile, 'a').close()
    except:
        print('Failed to create the preference file')
        sys.exit(1)

print('Writing content to preference file')

# Read the file
with open(preferencesfile) as json_file:
    try:
        json_decoded = json.load(json_file)
    except ValueError:
        json_decoded = {}

# Set the Values
# browser section
json_decoded['browser'] = {}
json_decoded['browser']['check_default_browser'] = False
json_decoded['browser']['show_home_button'] = True
json_decoded['browser']['show_update_promotion_info_bar'] = False
json_decoded['browser']['has_seen_welcome_page'] = True

# distribution section
json_decoded['distribution'] = {}
json_decoded['distribution']['make_chrome_default'] = True
json_decoded['distribution']['show_welcome_page'] = False
json_decoded['distribution']['skip_first_run_ui'] = True
json_decoded['distribution']['suppress_first_run_bubble'] = True
json_decoded['distribution']['suppress_first_run_default_browser_prompt'] = True

# Save changes
with open(preferencesfile, 'w+') as json_file:
    json.dump(json_decoded, json_file)

# Re-permission directories
try:
    subprocess.call(['chown', '-R', username, preferencesdirectory])
except:
    print('Failed to permission the preference file directory')
    sys.exit(1)

print('Script Completed')
sys.exit(0)
