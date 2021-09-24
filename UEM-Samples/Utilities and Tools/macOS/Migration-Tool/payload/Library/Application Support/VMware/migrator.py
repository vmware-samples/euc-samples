#!/usr/bin/python
# encoding: utf-8
#
# Copyright 2020 VMware Inc.
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Migrator
# This script orchestrates the migration process of a macOS device from one management
# system to another. It is designed to be used with DEPNotify.

from Foundation import NSBundle, NSLog
from SystemConfiguration import SCDynamicStoreCopyConsoleUser
import objc, os, platform, re, shutil, subprocess, sys, time, uuid
import json, plistlib
import optparse
import urllib, urllib2


WorkspaceServicesProfile = 'Workspace Services'
DeviceManagerProfile = 'Device Manager'
depnotifylog = '/private/var/tmp/depnotify.log'
depnotifypath = '/Applications/Utilities/DEPNotify.app'
hubpath = 'https://packages.vmware.com/wsone/VMwareWorkspaceONEIntelligentHub.pkg'

migratorpath = '/Library/Application Support/VMware/migrator.py'
resourcesdir='/Library/Application Support/VMware/MigratorResources/'
ldpath = '/Library/LaunchDaemons/com.vmware.migrator.plist'
ldidentifier = 'com.vmware.migrator'

def oslog(text):
    try:
        NSLog('[Migrator] ' + str(text))
    except Exception as e: #noqa
        print e
        print '[Migrator] ' + str(text) #try to catch it in the LD log - /var/log/vmw_migrator.log


def depnotify(text):
    oslog('[DEPNotify] ' + str(text))
    with open(depnotifylog, 'a+') as log:
        log.write(str(text) + '\n')


def getcurrentconsoleuser():
    # https://macmule.com/2014/11/19/how-to-get-the-currently-logged-in-user-in-a-more-apple-approved-way/
    cfuser = SCDynamicStoreCopyConsoleUser(None, None, None)
    return cfuser #returns a 3-tuple - (Username, UID, GroupID) - so username is cfuser[0]


def getdeviceinfo():
    deviceinfo = {}
    try:
        cmd = ['/usr/sbin/system_profiler', '-xml', 'SPHardwareDataType']
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, err = proc.communicate()
        plist = plistlib.readPlistFromString(output)
        deviceinfo['type'] = plist[0]['_items'][0]['machine_name'] #e.g. MacBook Pro
        deviceinfo['model'] = plist[0]['_items'][0]['machine_model'] #e.g. MacBookPro14,3
        deviceinfo['uuid'] = plist[0]['_items'][0]['platform_UUID']
        deviceinfo['serial'] = plist[0]['_items'][0]['serial_number']
    except Exception as e: #noqa
        oslog('Error getting system info via system_profiler')
        oslog(str(e))
        depnotify('Command: WindowStyle: Activate')
        depnotify('Command: Quit: Error getting system info')
        cleanup()
    else:
        deviceinfo['osvers'] = platform.mac_ver()[0] #OS Version, e.g. 10.14.1
        return deviceinfo


def installpkg(path):
    try:
        cmd = ['sudo', '/usr/sbin/installer', '-pkg', path, '-target', '/']
        oslog(cmd)
        proc = subprocess.Popen(cmd, shell=False, bufsize=-1,
                                stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        output, rcode = proc.communicate(), proc.returncode
        oslog('Result Code - %s' % str(rcode))
        return rcode
    except Exception as e: #noqa
        oslog(e)
        return None


def runcmd(*arg):
    # Use *arg to pass unlimited variables to command
    cmd = arg
    oslog(cmd)
    try:
        run = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, err = run.communicate()
        oslog('stdout - %s' % str(output))
        return output
    except Exception as e: #noqa
        oslog(e)
        return None


def init_registration(consoleuser, username=True, email=False):
    # delete registration done file if it exists
    runcmd('/bin/rm', '-f', '/var/tmp/com.depnotify.registration.done')
    # create plist for setup Registration fields in ~/Library/Preferences/menu.nomad.DEPNotify.plist
    runcmd('sudo', '-u', consoleuser, 'defaults', 'write', 'menu.nomad.DEPNotify',  'pathToPlistFile', '/Users/Shared/UserInput.plist')
    runcmd('sudo', '-u', consoleuser, 'defaults', 'write', 'menu.nomad.DEPNotify',  'registrationButtonLabel', 'Continue')

    if username:
        runcmd('sudo', '-u', consoleuser, 'defaults', 'write', 'menu.nomad.DEPNotify', 'registrationMainTitle', 'Enter your username')
        # runcmd('sudo', '-u', consoleuser, 'defaults', 'write', 'menu.nomad.DEPNotify', 'textField1Placeholder', 'johndoe')
        runcmd('sudo', '-u', consoleuser, 'defaults', 'write', 'menu.nomad.DEPNotify', 'textField1Label', 'Username')
        runcmd('sudo', '-u', consoleuser, 'defaults', 'write', 'menu.nomad.DEPNotify', 'textField1RegexPattern', '[A-Z0-9a-z.-_@]')

    if email:
        runcmd('sudo', '-u', consoleuser, 'defaults', 'write', 'menu.nomad.DEPNotify', 'registrationMainTitle', 'Enter your email')
        # runcmd('sudo', '-u', consoleuser, 'defaults', 'write', 'menu.nomad.DEPNotify', 'textField1Placeholder', 'johndoe@acme.org')
        runcmd('sudo', '-u', consoleuser, 'defaults', 'write', 'menu.nomad.DEPNotify', 'textField1Label', 'Email')
        runcmd('sudo', '-u', consoleuser, 'defaults', 'write', 'menu.nomad.DEPNotify', 'textField1RegexPattern', '[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}')


def wait_for_input(username=True, email=False):
    path = '/Users/Shared/UserInput.plist'
    done = '/var/tmp/com.depnotify.registration.done'
    runcount = 0
    value = None
    oslog('Waiting for user input...')
    while runcount < 300:
        done_exists = os.path.isfile(done)
        if done_exists:
            try:
                plist = plistlib.readPlist(path)
            except IOError,e:
                oslog(e.read())
                depnotify('Command: WindowStyle: Activate')
                depnotify('Command: Quit: Error reading user input')
                cleanup()
            if username:
                try:
                    value = plist['Username']
                except KeyError,e:
                    oslog(e.read())
                    depnotify('Command: WindowStyle: Activate')
                    depnotify('Command: Quit: Error reading user input')
                    cleanup()
                oslog('User entered \'%s\' for username' % value)
                break
            if email:
                try:
                    value = plist['Email']
                except KeyError,e:
                    oslog(e.read())
                    depnotify('Command: WindowStyle: Activate')
                    depnotify('Command: Quit: Error reading user input')
                    cleanup()
                oslog('User entered \'%s\' for email' % value)
                break
        else:
            runcount = runcount + 1
            time.sleep(2) #300 tries every 2 seconds = 600seconds = 10 minute timeout

    if value is not None:
        return value
    else:
        depnotify('Status: Migration has failed - Timeout after no input received.')
        oslog('Migration has failed - Timeout after no input received.')
        depnotify('Command: WindowStyle: Activate')
        depnotify('Command: Quit: Migration has failed - Timeout after no input received.')
        cleanup()

def wait_for_unenrollment():
    profilelist = runcmd('sudo', '/usr/bin/profiles', '-vP')
    if 'com.apple.mdm' in profilelist:
        oslog('Device is enrolled - com.apple.mdm payload found')
        not_enrolled = False
        runcount = 0
        while runcount < 270:
            profilelist = runcmd('sudo', '/usr/bin/profiles', '-vP')
            if 'com.apple.mdm' in profilelist:
                oslog('Still enrolled, waiting for unenrollment...')
            else:
                oslog('Unenrollment detected - no com.apple.mdm payload found')
                not_enrolled = True
                break
            runcount = runcount + 1
            time.sleep(2) #270 tries every 2 seconds = 540seconds = 9 minute timeout
                          #Enrollment profile has a 10minute
    else:
        oslog('Device is not enrolled - no com.apple.mdm payload found')
        not_enrolled = True


def runrootscript(pathname, wait=False):
    # Credit Erik Gomez from InstallApplications
    '''Runs script located at given pathname'''
    try:
        if wait:
            oslog('Running Script: %s ' % (str(pathname)))
            proc = subprocess.Popen(pathname, stdout=subprocess.PIPE,
                                    stderr=subprocess.PIPE)
            (out, err) = proc.communicate()
            if err and proc.returncode == 0:
                oslog('Output from %s on stderr but ran successfully: %s' %
                       (pathname, err))
            elif proc.returncode > 0:
                oslog('Received non-zero exit code: ' + str(err))
                return False
        else:
            oslog('Do not wait triggered')
            proc = subprocess.Popen(pathname)
            oslog('Running Script: %s ' % (str(pathname)))
    except OSError as err:
        oslog('Failure running script: ' + str(err))
        return False
    return True


def cleanup(reboot=False):
    oslog('Cleaning up... DEPNotify.app will not be removed...')
    oslog('Attempting to delete LaunchDaemon plist: ' + ldpath)
    try:
        os.remove(ldpath)
    except:  # noqa
        pass

    oslog('Attempting to delete Migrator script: ' + migratorpath)
    try:
        os.remove(migratorpath)
    except:  # noqa
        pass

    oslog('Attempting to delete Migrator Resources directory: ' + resourcesdir)
    try:
        shutil.rmtree(resourcesdir)
    except:  #noqa
        pass

    oslog('Attempting to delete DEPNotify log: ' + depnotifylog)
    try:
        os.remove(depnotifylog)
    except:  # noqa
        pass

    if not reboot:
        oslog('Attempting to remove LaunchDaemon from launchctl: ' + ldidentifier)
        runcmd('/bin/launchctl', 'remove', ldidentifier)
        oslog('Cleanup done. Exiting.')
        sys.exit(0)


def main():
    # Options
    usage = '%prog [options]'
    o = optparse.OptionParser(usage=usage)
    o.add_option('--custom', default=False, help='Use for migration from a different MDM vendor',
                 action='store_true')
    o.add_option('--removal-script', default=None,
                 help='Specify the path of a script to execute to remove the prior MDM vendor.')
    o.add_option('--wsone', default=False, help='Use for Workspace ONE UEM migration',
                 action='store_true')

    o.add_option('--origin-apiurl', default=None,
                 help='Required with --wsone: API URL for Origin Server')
    o.add_option('--origin-auth', default=None,
                 help='Required with --wsone: Base64 Auth for Origin Server')
    o.add_option('--origin-token', default=None,
                 help='Required with --wsone: API Token for Origin Server')

    o.add_option('--prompt-username', default=False,
                 help='Prompt user to enter enrollment username',
                 action='store_true')
    o.add_option('--prompt-email', default=False,
                 help='Prompt user to enter enrollment user email',
                 action='store_true')

    o.add_option('--dest-baseurl', default=None,
                 help='Required: Base URL for Destination Enrollment Server')
    o.add_option('--dest-auth', default=None,
                 help='Required: Base64 Auth for Destination Server')
    o.add_option('--dest-token', default=None,
                 help='Required: API Token for Destination Server')
    o.add_option('--dest-groupid', default=None,
                 help='Required: Group ID to enroll on Destination Server')
    o.add_option('--dest-apiurl', default=None,
                 help='Optional: Specify the Base URL for Destination API Server')

    o.add_option('--sideload-mode', default=False,
                 help='Optional: Must be used with an exported enrollment profile distributed via this package',
                 action='store_true')
    o.add_option('--enrollment-profile-path', default=None,
                 help='Optional: Specify the full path where the exported enrollment profile will reside. \
                       Defaults to /Library/Application Support/VMware/MigratorResources/*.mobileconfig')

    o.add_option('--predepnotify-script', default=None,
                 help='Optional: Specify the path of a script to execute before DEPNotify opens. \
                       Use this to customize DEPNotify branding before it launches.')
    o.add_option('--premigration-script', default=None,
                 help='Optional: Specify the path of a script to execute before removing the origin profile')
    o.add_option('--donotwait-for-premig', default=False, action='store_true',
                 help='Optional: Specify to start origin removal even if the pre-mig script is still running')
    o.add_option('--midmigration-script', default=None,
                 help='Optional: Specify the path of a script to execute mid-migration, which is \
                       after the origin is removed but before the new enrollment begins')
    o.add_option('--postmigration-script', default=None,
                 help='Optional: Specify the path of a script to execute post-migration, right before cleanup & exit')

    o.add_option('--prompt-for-restart', default=False, action='store_true',
                 help='Optional: Prompt the user to restart at the end, via DEPNotify')
    o.add_option('--forced-restart-delay', default=None,
                 help='Optional: Specify number of seconds to delay auto reboot after migration is complete.')

    opts, args = o.parse_args()

    oslog('Beginning migration run...')

    # initialize variables
    baseurl = opts.dest_baseurl
    groupid = opts.dest_groupid
    header_auth = opts.dest_auth
    header_token = opts.dest_token
    HEADERS = {}
    HEADERS['Authorization'] = header_auth
    HEADERS['aw-tenant-code'] = header_token
    HEADERS['Accept'] = 'application/json'
    HEADERS['Content-Type'] = 'application/json'

    if opts.dest_apiurl:
        apiurl = opts.dest_apiurl
    else:
        apiurl = baseurl

    if opts.origin_apiurl:
        originurl = opts.origin_apiurl

    if opts.origin_auth:
        originauth = opts.origin_auth

    if opts.origin_token:
        origintoken = opts.origin_token

    #Get Basic Device information
    deviceinfo = getdeviceinfo()
    deviceserial = deviceinfo['serial']
    devicetype = deviceinfo['type']
    devicemodel = deviceinfo['model']
    deviceuuid = deviceinfo['uuid']
    deviceosversion = deviceinfo['osvers']
    oslog('OS Version is %s' % deviceosversion)
    oslog('Serial Number is %s' % deviceserial)
    oslog('Device type is %s' % devicetype)
    oslog('Device model is %s' % devicemodel)
    oslog('Device UUID is %s' % deviceuuid)
    cfuser = getcurrentconsoleuser() # get info on logged in user
    consoleuser = cfuser[0]
    oslog('Current logged in username is %s' % consoleuser)

    #Create new log file for DEPNotify to watch
    oslog('Initializing DEPNotify Log path at: %s' % depnotifylog)
    runcmd('/bin/rm', '-f', depnotifylog)
    runcmd('/usr/bin/touch', depnotifylog)
    runcmd('/bin/chmod', '644', depnotifylog)

    if opts.predepnotify_script:
        oslog('--predepnotify-script detected')
        scriptpath = opts.predepnotify_script
        runrootscript(scriptpath, wait=True)
        time.sleep(1) #let the depnotify customizations bake before we open it

    oslog('Opening DEPNotify for user \'%s\'' % consoleuser)

    #runcmd('sudo', '-u', consoleuser, '/usr/bin/open', '-a', depnotifypath)
    os.spawnl(os.P_NOWAIT, '/usr/bin/open', '-a', depnotifypath)
    time.sleep(3)

    username = None
    useremail = None
    if not opts.sideload_mode:
        if opts.prompt_email:
            oslog('--prompt-email option used')
            oslog('Invoking DEPNotify to prompt for enrollment user email')
            init_registration(consoleuser, username=False, email=True)
            depnotify('Status: Click button and enter your email')
            depnotify('Command: ContinueButtonRegister: Enter Email')
            useremail = wait_for_input(username=False, email=True)
        elif opts.prompt_username:
            oslog('--prompt-username option used')
            oslog('Invoking DEPNotify to prompt for enrollment username')
            init_registration(consoleuser, username=True, email=False)
            depnotify('Status: Click Button and enter your username')
            depnotify('Command: ContinueButtonRegister: Enter Username')
            username = wait_for_input(username=True, email=False)
        else:
            oslog('Warning - Neither --sideload-mode, --prompt-username, or --prompt-email used.')
            oslog('Using %s for enrollment username' % consoleuser)
            username = consoleuser

        #Query for User Information from Workspace ONE UEM
        depnotify('Status: Validating user for migration')
        if not opts.prompt_email:
            url = apiurl + '/api/system/users/search?username=' + username
            oslog('Querying server for ID for %s' % username)
            oslog('GET - ' + url)
        else:
            url = apiurl + '/api/system/users/search?email=' + useremail
            oslog('Querying server for ID for %s' % useremail)
            oslog('GET - ' + url)

        try:
            req = urllib2.Request(url=url, headers=HEADERS)
            response = urllib2.urlopen(req).read()
            oslog('Raw Response - ' + str(response))
        except IOError, e:
            if hasattr(e, 'reason'):
                oslog('Failed - Reason: %s' % str(e.reason))
            elif hasattr(e, 'code'):
                oslog('Failed - Error code: %s' % str(e.code))
            oslog(e.read())
            depnotify('Command: WindowStyle: Activate')
            depnotify('Command: Quit: Error retrieving User Info from WSONE')
            cleanup()

        try:
            uinfo = json.loads(response)
        except ValueError: #if the response can't be converted to json, quit
            oslog('Error parsing User Info from WSONE into JSON')
            depnotify('Command: WindowStyle: Activate')
            depnotify('Command: Quit: Error parsing User Info from WSONE')
            cleanup()

        #Parse through user information for the WSONE UserID
        #If we get more than one match, iterate through to find the exact string match
        userID = ''
        if len(uinfo['Users']) > 1:
            for u in uinfo['Users']:
                if username == u['UserName']:
                    userID = u['Id']['Value']
                    break
                elif useremail == u['Email']:
                    userID = u['Id']['Value']
                    break
                else:
                    continue
        else:
            userID = uinfo['Users'][0]['Id']['Value']

        if userID == '': #if the above parsing comes back with nothing, quit
            oslog('Unknown WSONE User ID')
            depnotify('Command: WindowStyle: Activate')
            depnotify('Command: Quit: Unable to find user in WSONE, quitting...')
            cleanup()


        ##### REGISTRATION ######
        oslog('User %s UserID is %s' % (username, userID))
        depnotify('Status: Registering device and getting enrollment token from Workspace ONE UEM...')

        #Create Registration Token for the User with User ID and Serial Number
        registration = {}
        registration["PlatformId"] = 10 #10 = macOS
        registration["MessageType"] = 0 #0 = email notification
        registration["ToEmailAddress"] = "noreply@vmware.com" #redirecting the email to a noreply address.
        registration["Ownership"] = "C" #default all devices to enroll as Corporate Owned ownership type
        registration["LocationGroupId"] = groupid
        registration["SerialNumber"] = deviceserial
        registration["FriendlyName"] = "%s\'s %s" % (username, devicetype) #jdoe's MacBook Pro

        oslog('Registering device with...')
        oslog(str(registration))
        url = apiurl + '/api/system/users/%s/registerdevice' % userID
        oslog('POST - ' + url)
        data = json.dumps(registration).encode('utf-8')
        dlen = len(data)
        HEADERS['Content-Length'] = dlen

        try:
            req = urllib2.Request(url=url, data=data, headers=HEADERS)
            response = urllib2.urlopen(req).read()
            oslog('Raw Response - ' + str(response))
        except IOError, e:
            if hasattr(e, 'reason'):
                oslog('Failed - Reason: %s' % str(e.reason))
            elif hasattr(e, 'code'):
                oslog('Failed - Error code: %s' % str(e.code))
            oslog(e.read())
            depnotify('Command: WindowStyle: Activate')
            depnotify('Command: Quit: Unable to register device with WSONE')
            cleanup()

        regtoken = response.replace('\"', '')
        depnotify('Status: One-Time registration token created for User %s: %s' % (username, regtoken))
        oslog('Fetching enrollment profile with enrollment info:')

        enrollmentinfo = {}
        enrollmentinfo["Header"] = {"Language":"en-US", "ProcotolRevision":"5", "Mode":"2"}
        enrollmentinfo["GroupId"] = regtoken
        enrollmentinfo["CaptchaValue"] = ""
        enrollmentinfo["GroupIDSource"] = "1"
        enrollmentinfo["SamlCompleteUrl"] = ""
        enrollmentinfo["Device"] = {
            "Serial": deviceserial,
            "InternalIdentifier": str(uuid.uuid4()).replace('-', ''),
            "Type": "10",
            "BundleIdentifier": deviceuuid,
            "OsVersion": deviceosversion,
            "Identifier": deviceuuid,
            "Model": devicetype,
            "Product": devicemodel
        }

        agent_header = {}
        agent_header['User-Agent'] = 'airwatchd (unknown version) CFNetwork/975.0.3 Darwin/18.2.0 (x86_64)'
        agent_header['Content-Type'] = 'application/json'
        agent_header['Accept'] = 'application/json'

        data = json.dumps(enrollmentinfo)
        data = data.encode('utf-8')
        dlen = len(data)
        agent_header['Content-Length'] = dlen

        try:
            url = baseurl + '/DeviceServices/AirwatchEnroll.aws/Enrollment/validateGroupIdentifier'
            req = urllib2.Request(url, data=data, headers=agent_header)
            response = urllib2.urlopen(req).read()
            oslog('Raw Response - %s' % str(response))
        except IOError, e:
            if hasattr(e, 'reason'):
                oslog('Failed - Reason: %s' % str(e.reason))
            elif hasattr(e, 'code'):
                oslog('Failed - Error code: %s' % str(e.code))
            oslog(e.read())
            depnotify('Command: WindowStyle: Activate')
            depnotify('Command: Quit: Error initiating WSONE Enrollment')
            cleanup()

        try:
            resp = json.loads(response)
            sid = resp["Header"]["SessionId"]
            oslog('Enrollment Session ID: %s' % sid)
        except Exception as e:
            oslog(e)
            oslog('Error finding enrollment session ID')
            depnotify('Command: WindowStyle: Activate')
            depnotify('Command: Quit: Error finding enrollment session ID.')
            cleanup()

        mdmheader = enrollmentinfo["Header"]
        mdmheader["SessionId"] = sid
        enrollmentinfo["Header"] = mdmheader
        enrollmentinfo["oem"] = "mac"

        enrollmentinfo.pop("GroupId")
        enrollmentinfo.pop("CaptchaValue")
        enrollmentinfo.pop("GroupIDSource")
        enrollmentinfo.pop("SamlCompleteUrl")

        data = json.dumps(enrollmentinfo)
        data = data.encode('utf-8')
        dlen = len(data)
        agent_header['Content-Length'] = dlen

        try:
            url = baseurl + '/DeviceServices/AirwatchEnroll.aws/Enrollment/createMdmInstallUrl'
            req = urllib2.Request(url, data=data, headers=agent_header)
            response = urllib2.urlopen(req).read()
            oslog('Raw Response - %s' % str(response))
        except IOError, e:
            if hasattr(e, 'reason'):
                oslog('Failed - Reason: %s' % str(e.reason))
            elif hasattr(e, 'code'):
                oslog('Failed - Error code: %s' % str(e.code))
            oslog(e.read())
            depnotify('Command: WindowStyle: Activate')
            depnotify('Command: Quit: Error getting WSONE Enrollment profile download url')
            cleanup()

        try:
            resp = json.loads(response)
            enrollprofileurl = resp["NextStep"]["InstallUrl"]
            oslog('Enrollment Profile URL: %s' % enrollprofileurl)
        except Exception as e:
            oslog(e)
            oslog('Error finding Enrollment Profile URL')
            depnotify('Command: WindowStyle: Activate')
            depnotify('Command: Quit: Error getting WS1 Enrollment profile download url')
            cleanup()
        else:
            oslog('Downloading Enrollment Profile')
            depnotify('Status: Downloading Workspace ONE UEM enrollment profile')
            urllib.urlretrieve(enrollprofileurl, '/Library/Application Support/VMware/MigratorResources/*.mobileconfig')
            oslog('Downloaded to /Library/Application Support/VMware/MigratorResources/*.mobileconfig')
    else:
        oslog('--sideload-mode option used')
        if not opts.enrollment_profile_path:
            oslog('Error - Sideload Mode used but no enrollment profile path defined...')
            depnotify('Command: WindowStyle: Activate')
            depnotify('Command: Quit: Missing enrollment profile file location, quitting...')
            cleanup()

    if opts.premigration_script:
        oslog('--premigration-script detected')
        scriptpath = opts.premigration_script
        if opts.donotwait_for_premig:
            runrootscript(scriptpath, wait=False)
        else:
            runrootscript(scriptpath, wait=True)

    if opts.custom:
        #Remove MDM vendor with custom script
        oslog('Removing Custom')
        depnotify('Status: Removing prior management')
        scriptpath = opts.removal_script
        runrootscript(scriptpath, wait=True)
        wait_for_unenrollment()

    if opts.wsone:
        #Remove Workspace ONE UEM (formerly known as AirWatch)
        oslog('Removing Workspace ONE UEM')
        depnotify('Status: Removing Workspace ONE UEM')
        runcmd('/bin/bash', '/Library/Scripts/hubuninstaller.sh')
        runcmd('/bin/rm', '-rf', '/Library/Application Support/AirWatch/')
        ORIGIN_HEADERS = {}
        url = originurl + '/api/mdm/devices/commands?command=EnterpriseWipe&searchBy=Serialnumber&id=' + deviceserial
        ORIGIN_HEADERS['Authorization'] = originauth
        ORIGIN_HEADERS['aw-tenant-code'] = origintoken
        ORIGIN_HEADERS['Accept'] = 'application/json'
        ORIGIN_HEADERS['Content-Type'] = 'application/json'
        oslog('POST - ' + url)
        try:
            req = urllib2.Request(url, data="", headers=ORIGIN_HEADERS)
            response = urllib2.urlopen(req).read()
            oslog('Raw Response - ' + str(response))
        except IOError, e:
            if hasattr(e, 'reason'):
                oslog('Failed - Reason: %s' % str(e.reason))
            elif hasattr(e, 'code'):
                oslog('Failed - Error code: %s' % str(e.code))
                oslog(e.read())
            depnotify('Command: WindowStyle: Activate')
            depnotify('Command: Quit: Error requesting unenrollment from origin server')
            cleanup()
        else:
            wait_for_unenrollment()


    #Kill System Preferences before attempting enrollment (prevents issues opening profile)
    runcmd('sudo', '-u', consoleuser, 'killall', 'System Preferences')

    #run mid-migration script if provided
    if opts.midmigration_script:
        oslog('--midmigration-script detected')
        depnotify('Status: Getting ready for enrollment to Workspace ONE...')
        scriptpath = opts.midmigration_script
        runrootscript(scriptpath, wait=True)
        depnotify('Status: Ready to enroll')

    #initialize enrollment profile path depending on the mode
    enrollmentProfilePath = ''
    if opts.sideload_mode:
        if opts.enrollment_profile_path:
            enrollmentProfilePath = opts.enrollment_profile_path
    else:
        enrollmentProfilePath = '/Library/Application Support/VMware/MigratorResources/*.mobileconfig'

    #Opening the profile, which opens System Preferences > Profiles pane,
    # the user would need to go through the GUI prompts to install the profile (enroll)
    #This method keeps the enrollment User Approved in 10.13.2+
    depnotify('Status: Please proceed through the System Prompts to install the enrollment profile')
    oslog('Opening profile to begin enrollment')
    if deviceosversion >= '11.0':
        runcmd('sudo', '-u', consoleuser, '/usr/bin/open', enrollmentProfilePath)
        runcmd('sudo', '-u', consoleuser, '/usr/bin/open', '-b', 'com.apple.systempreferences', '/System/Library/PreferencePanes/Profiles.prefPane')
    elif deviceosversion >= '10.15.1':
        runcmd('sudo', '-u', consoleuser, '/usr/bin/open', '-a', '/System/Applications/System Preferences.app', enrollmentProfilePath)
    else:
        runcmd('sudo', '-u', consoleuser, '/usr/bin/open', '-a', '/Applications/System Preferences.app', enrollmentProfilePath)

    runcount = 0
    enrolled = False #In case the MDM Profile is never found, this will remain False
    #Check if MDM profile is installed (enrolled), checks every 2 seconds
    #If profile name is found, change 'enrolled' to True and break from the loop
    #Otherwise, after 100 tries, the loop will break and 'enrolled' will remain False
    while runcount < 180:
        profilelist = runcmd('sudo', '/usr/bin/profiles', '-vP')
        if WorkspaceServicesProfile in profilelist:
            oslog('Successfully Enrolled - Workspace Services profile detected')
            enrolled = True
            break
        elif DeviceManagerProfile in profilelist:
            oslog('Successfully Enrolled - Device Manager profile detected')
            enrolled = True
            break
        #this part only executes if the loop hasn't been broken out of
        oslog('MDM profile not found, checking again...')
        runcount = runcount + 1
        time.sleep(3) #180 tries every 3 seconds = 540seconds = 9 minute timeout

    depnotify('Command: WindowStyle: Activate')
    #Check value of 'enrolled' to know whether the MDM Profile was found or not
    if enrolled: #enrolled = True - Tell the user enrollment succeeded and clean up
        runcmd('sudo', '-u', consoleuser, 'killall', 'System Preferences')
        depnotify('Command: WindowStyle: Activate')
        try:
            oslog('Downloading Workspace ONE Intelligent Hub...')
            depnotify('Status: Downloading Workspace ONE Intelligent Hub...')
            urllib.urlretrieve(hubpath, '/tmp/ws1hub.pkg')
        except IOError, e:
            if hasattr(e, 'reason'):
                oslog('Failed - Reason: %s' % str(e.reason))
            elif hasattr(e, 'code'):
                oslog('Failed - Error code: %s' % str(e.code))
            oslog(e.read())
            depnotify('Status: Error downloading Workspace ONE Intelligent Hub. Download manually from getwsone.com.')
            pass
        else:
            oslog('Installing Workspace ONE Intelligent Hub...')
            depnotify('Status: Installing Workspace ONE Intelligent Hub...')
            installpkg('/tmp/ws1hub.pkg')
            depnotify('Status: Enrollment complete!')
        time.sleep(2)
        #run post-migration script if provided
        if opts.postmigration_script:
            oslog('--postmigration-script detected')
            depnotify('Status: Finishing up, running post-migration script...')
            scriptpath = opts.postmigration_script
            runrootscript(scriptpath, wait=True)

        if opts.prompt_for_restart:
            oslog('--prompt-for-restart detected')
            depnotify('Command: WindowStyle: Activate')
            depnotify('Status: Please restart now to complete the migration.')
            depnotify('Command: Restart: Please restart now')
            cleanup()
        elif opts.forced_restart_delay:
            try:
                delay = int(opts.forced_restart_delay)
            except:  #noqa
                delay = 15
            oslog('--forced-restart-delay detected')
            depnotify('Command: WindowStyle: Activate')
            depnotify('Status: Your computer will automatically restart in %s seconds. Please login normally to complete the migration.' % str(delay))
            depnotify('Command: Quit: Your computer will restart in %s seconds.' % str(delay))
            time.sleep(delay)
            cleanup(reboot=True)
            oslog('Triggering reboot now')
            time.sleep(1)
            subprocess.call(['/sbin/shutdown', '-r', 'now'])
        else:
            depnotify('Command: WindowStyle: Activate')
            depnotify('Command: Quit: Your device is now migrated.')
            cleanup()

    else: #enrolled = False - Tell the user enrollment failed and clean up
        depnotify('Command: WindowStyle: Activate')
        depnotify('Status: Enrollment has failed - MDM Profile not found.')
        oslog('Enrollment has failed - MDM Profile not found.')
        depnotify('Command: Quit: Enrollment has failed - MDM Profile not found')
        cleanup()


if __name__ == '__main__':
    main()
