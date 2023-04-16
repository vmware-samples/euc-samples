#!/usr/bin/python
#
# This script waits to run until the Dock process is present. It will add the
# webloc file (created in the postinstall) to the current console user's dock.
#
# After the first run, a runonce file is created at ~/.appcatalog_runonce
# If the LaunchAgent is invoked, the script will exit if this file exists
#
# v1.0 - 4/26/18

import Cocoa
import os
import plistlib
import subprocess
import sys
import time
from SystemConfiguration import SCDynamicStoreCopyConsoleUser

icon_filepath = '/Users/Shared/VMware/Catalog.png'
webloc_filepath = '/Users/Shared/VMware/Catalog.webloc'

def getconsoleuser():
    cfuser = SCDynamicStoreCopyConsoleUser(None, None, None)
    return cfuser

def touch(path):
    try:
        print 'Creating file: %s' % path
        proc = subprocess.Popen(['/usr/bin/touch', path], stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        output, err = proc.communicate()
        os.chmod(path, 0666)
        print 'Successfully created file: %s' % path
    except Exception as e:
        print 'Error creating file: %s' % e


def addtodock(dockdata):
    curruser = getconsoleuser()
    dockplist = '/Users/%s/Library/Preferences/com.apple.dock.plist' % curruser[0]
    runoncefile = '/Users/%s/.appcatalog_runonce' % curruser[0]
    try:
        cmd = ['defaults', 'write', 'com.apple.dock', 'persistent-others', '-array-add', dockdata]
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, err = proc.communicate()
        os.chmod(dockplist, 0600)
        os.chown(dockplist, curruser[1], curruser[2])
        subprocess.call(['killall', 'Dock'])
        touch(runoncefile)
    except Exception as e:
        print 'Error setting dock: %s' % e
        pass

def seticon(iconpath, filepath):
    try:
        Cocoa.NSWorkspace.sharedWorkspace().setIcon_forFile_options_(Cocoa.NSImage.alloc().initWithContentsOfFile_(iconpath.decode('utf-8')), filepath.decode('utf-8'), 0)
    except Exception as e:
        print 'Error setting icon: %s' % e
        pass

def main():
    # Check to see if this script has been run already or not
    curruser = getconsoleuser()
    runoncefile = '/Users/%s/.appcatalog_runonce' % curruser[0]

    if os.path.isfile(runoncefile):
        print 'Found ~/.appcatalog_runonce - aborting...'
        sys.exit(0)


    # set the icon of the webloc
    seticon(icon_filepath, webloc_filepath)

    # create XML data to insert into dock.plist
    webloc_url = 'file://' + webloc_filepath
    dockdata = """<dict>
        <key>tile-data</key>
        <dict>
            <key>file-data</key>
            <dict>
                <key>_CFURLString</key>
                <string>%s</string>
                <key>_CFURLStringType</key>
                <integer>15</integer>
            </dict>
            <key>file-label</key>
            <string>Catalog</string>
            <key>file-type</key>
            <integer>40</integer>
        </dict>
    </dict>""" % webloc_url

    # add webloc to dock
    addtodock(dockdata)


if __name__ == '__main__':
    # Wait to start the script until Dock process is loaded.
    # This is to prevent the script from modifying the Dock before login
    # process has completed and the Dock & UI processes loaded.
    i = 0
    while True:
        if i < 100:
            try:
                subprocess.check_output('/usr/bin/pgrep Dock', shell=True)
                print 'Dock process found'
                time.sleep(3) # Short delay to let Dock process fully load first
                break
            except Exception:
                i += 1
                print 'Dock process not found, checking again'
                time.sleep(1)
                pass
        else:
            print 'Dock process not found after 100 tries, aborting'
            sys.exit(1)

    main()
