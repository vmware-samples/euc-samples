#!/usr/bin/python3
#
# Helper tool to find required data for Workspace ONE UEM App Blocking functionality for macOS
#
# Created by Adam Matthews - adam@adammatthews.co.uk // matthewsa@vmware.com 
# Date: 6th July 2021
#

import subprocess, sys, getopt, re, argparse, os

parser = argparse.ArgumentParser()
parser.add_argument('--apps', help='Application Path')
parser.add_argument('--list', help='List applications', action='store_true')

args = parser.parse_args()

if args.apps:
	app = args.apps
	cmd = ["/usr/bin/codesign","-dv","--verbose=4",app]
	returned_value = subprocess.run(cmd, capture_output=True) # returns the exit code in unix

	out = returned_value.stderr

	cdhash = ""
	teamid = ""
	sha256 = ""
	name = ""
	bundleid = ""
	path = ""

	# get CDHash
	for line in out.splitlines():	
		result = str(line).find('CDHash',0,10)
		if result > 0:
			# print(line) #CDHash
			m = re.search('(?<=\=).*', str(line, 'utf-8').rstrip())
			cdhash = m.group(0)
	# get TeamIdentifier
	for line in out.splitlines():	
		result = str(line).find('TeamIdentifier',0,20)
		if result > 0:
			# print(line) #TeamID
			m = re.search('(?<=\=).*', str(line, 'utf-8').rstrip())
			teamid = m.group(0)

	# Get Sha-256 Hash
	list_files = subprocess.run(["ls", f"{app}/Contents/MacOS"], capture_output=True)
	sha_contents = str(list_files.stdout, 'utf-8').rstrip()
	name = sha_contents
	sha = ["/usr/bin/openssl","dgst","-sha256",f"{app}/Contents/MacOS/{sha_contents}"]
	sha_value = subprocess.run(sha, capture_output=True) # returns the exit code in unix
	sha_out = sha_value.stdout
	# print(sha_contents)
	m = re.search('(?<=\=).*', str(sha_out, 'utf-8').rstrip())
	sha256 = m.group(0)

	bundle_plist = subprocess.run(["osascript", "-e", f"id of app \"{sha_contents}\""], capture_output=True)
	bundleid = str(bundle_plist.stdout, 'utf-8').strip()

	print(f"Name: {name}")
	print(f"File Path: {app}/Contents/MacOS")
	print(f"CD Hash: {cdhash}")
	print(f"Team ID: {teamid}")
	print(f"SHA-265: {sha256}")
	print(f"Bundle ID: {bundleid}")

if args.list:
	list_apps = subprocess.run(["ls"], capture_output=True, cwd="/Applications/")
	apps_list = list_apps.stdout

	list_system_apps = subprocess.run(["ls"], capture_output=True, cwd="/System/Applications/")
	system_apps_list = list_system_apps.stdout

	list_utility_apps = subprocess.run(["ls"], capture_output=True, cwd="/System/Applications/Utilities")
	utility_apps_list = list_utility_apps.stdout

	for line in apps_list.splitlines():	
		print(f"/Applications/{str(line,'utf-8')}")
	for line in system_apps_list.splitlines():		
		print(f"/System/Applications/{str(line,'utf-8')}")
	for line in utility_apps_list.splitlines():		
		print(f"/System/Applications/Utilities/{str(line,'utf-8')}")