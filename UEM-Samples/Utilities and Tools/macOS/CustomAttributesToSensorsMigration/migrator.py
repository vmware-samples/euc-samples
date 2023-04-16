from Foundation import NSBundle, NSLog
import urllib, urllib2
import sys
import os
import json
import base64
import glob


#sensorpath = os.path.join("~", "Documents", "VMware", "WorkspaceONESensorMigration") #"~/Documents/VMware/WorkspaceOneSensorMigration/"
sensorpath = "SensorData/"

def oslog(text):
    try:
        NSLog('[SensorMigrator] ' + str(text))
    except Exception as e: #noqa
        print(e)
        #print('[SensorMigrator] ' + str(text))

def getCAProfiles(auth, settings):
    #Get Profile List
    responselist = getProfileList(auth, settings)
    profilelist = responselist['ProfileList']
    
    for profile in profilelist:
        # print(profile)
        profileData = getProfileById(auth, settings, profile)
        assignments = profile["AssignmentSmartGroups"]
        converted = convertToSensor(profileData, profile["OrganizationGroupUuid"], assignments)
        
        converted["query_type"] = determineLanguage(converted)
        converted["script_data"] = base64.b64decode(converted["script_data"]).decode('utf-8')

        saveToFile(converted)

def determineLanguage(data):
	script = base64.b64decode(data["script_data"]).decode('utf-8')
	first = script.partition('\n')[0]

	if ("#!/" in first):
		if ("zsh" in first):
			return "ZSH"
		elif ("python" in first):
			return "PYTHON"
		else:
			return "BASH"
	else:
		return "BASH"

       
def saveToFile(data):
    filename = data["name"] + ".json"
    filepath = os.path.join(sensorpath, filename)

    with open(filepath, 'w+') as outfile:
        json.dump(data, outfile)

def convertName(name):
    if name[0].isdigit():
        name += name[0]
        name = name[1:]
        name = name.strip()

    name = name.lower()
    name = name.replace('-', '')
    name = " ".join(name.split())
    name = name.replace(' ', '_')

    return name

def getProfileList(auth, settings):
    apiendpoint = '/api/mdm/profiles/search?platform=AppleOsX&status=Active&payloadName=CustomAttribute&pagesize=500'
    url = 'https://' + settings['APIServer'] + apiendpoint

    headers = {'Authorization':auth,
          'AW-Tenant-Code':settings["APIKey"],
          'Accept':'application/json;version=2',
          'Content-Type': 'application/json;version=2'}

    try:
    	oslog("Getting Profile List...")
    	req = urllib2.Request(url=url, headers=headers)
    	resp = urllib2.urlopen(req).read()
    	ProfileData = json.loads(resp)
    	oslog("Proile List successfully retrieved.")
    	return ProfileData
    except Exception as err:
    	oslog(err)
   

def getProfileById(auth, settings, profile):
    apiendpoint = '/api/mdm/profiles/'
    url = 'https://' + settings['APIServer'] + apiendpoint + str(profile['ProfileId'])

    headers = {'Authorization':auth,
          'AW-Tenant-Code':settings["APIKey"],
          'Accept':'application/json;version=2',
          'Content-Type': 'application/json;version=2'}

    try:
    	oslog("Getting info for Profile: " + profile["ProfileName"])
    	req = urllib2.Request(url=url, headers=headers)
    	resp = urllib2.urlopen(req).read()
    	ProfileData = json.loads(resp)
    	oslog("Info retrieved successfully.")
    	return ProfileData
    except Exception as err:
    	oslog(err)

def getSmartGroupUUID(auth, settings, SmartGroup):
    apiendpoint = '/api/mdm/smartgroups/' + str(SmartGroup["Id"])
    url = 'https://' + settings['APIServer'] + apiendpoint

    headers = {'Authorization':auth,
          'AW-Tenant-Code':settings["APIKey"],
          'Accept':'application/json;version=2',
          'Content-Type': 'application/json;version=2'}

    try:
    	oslog("Getting Smart Group UUID for: " + SmartGroup["Name"])
    	req = urllib2.Request(url=url, headers=headers)
    	resp = urllib2.urlopen(req).read()
    	SGData = json.loads(resp)
    	oslog("Smart Group UUID: " + SGData["SmartGroupUuid"])
    	return SGData["SmartGroupUuid"]
    except Exception as err:
    	oslog(err)

def convertToSensor(profile, ogUUID, assignments):
    name = convertName(profile["CustomAttributes"][0]["AttributeName"])
    description = profile["General"]["Description"]
    data = profile["CustomAttributes"][0]["AttributeScript"]
    if "Events" in profile["CustomAttributes"][0]:
        triggerType = "EVENT"
        triggers = profile["CustomAttributes"][0]["Events"]
    else:
        triggerType = "SCHEDULE"
        triggers = []

    newTriggers = []
    for t in triggers:
    	newTriggers.append(convertName(t))
    triggers = newTriggers

    d = {"name": name,
         "description": description,
         "platform": "APPLE_OSX",
         "query_type": "BASH",
         "query_response_type": "STRING",
         "organization_group_uuid": ogUUID,
         "execution_context": "SYSTEM",
         "execution_architecture": "EITHER64OR32BIT",
         "script_data": data,
         "trigger_type": triggerType,
         "event_triggers": triggers,
         "smart_groups": assignments
         }

    return d

def uploadSensors(auth, settings):

    for filename in glob.glob(os.path.join(sensorpath, '*.json')):
        oslog("Found Sensor Data: " + filename)
        with open(filename) as sensorData_file:
            sensorData = json.load(sensorData_file)
        SensorInfo = createSensor(auth, settings, sensorData)

        if SensorInfo is not None and settings["KeepSensorAssignment"] == 1:
            AssignmentInfo = assignSensor(auth, settings, SensorInfo["uuid"], sensorData)

def getAuth(username, password):
    auth_s = username + ":" + password
    auth = bytes(auth_s)
    return 'Basic ' + base64.b64encode(auth).decode('utf-8')

def createSensor(auth, settings, sensorData):
    url = 'https://' + settings["APIServer"] + '/api/mdm/devicesensors/'
    d = {"name": sensorData["name"],
         "description": sensorData["description"],
         "platform": "APPLE_OSX",
         "query_type": sensorData["query_type"],
         "query_response_type": sensorData["query_response_type"],
         "trigger_type": "UNKNOWN",
         "organization_group_uuid": sensorData["organization_group_uuid"],
         "execution_context": sensorData["execution_context"],
         "execution_architecture": "EITHER64OR32BIT",
         "script_data": base64.b64encode(sensorData["script_data"]).decode('utf-8'),
         "timeout": 0,
         "event_trigger": [
             0
         ],
         "schedule_trigger": "UNKNOWN"
         }
    data = json.dumps(d).encode("utf-8")
    headers = {'Authorization':auth,
          'AW-Tenant-Code':settings["APIKey"],
          'Accept':'application/json;version=2',
          'Content-Type': 'application/json'}

    try:
        oslog("Creating Sensor...")
    	req = urllib2.Request(url=url, data=data, headers=headers)
    	resp = urllib2.urlopen(req).read()
    	SensorJSON = json.loads(resp)
        oslog("Sensor successfully created: " + SensorJSON["uuid"])
        return SensorJSON
    except Exception as err:
        oslog(err)

def assignSensor(auth, settings, sensorUUID, SensorData):
    url = 'https://' + settings["APIServer"] + '/api/mdm/devicesensors/' + sensorUUID + '/assignment'
    sgUUIDs = []
    for sg in SensorData["smart_groups"]:
    	sgUUID = getSmartGroupUUID(auth, settings, sg)
    	sgUUIDs.append(sgUUID)
    d = {"name": "Assignment Group 1",
         "smart_group_uuids": sgUUIDs,
         "trigger_type": SensorData["trigger_type"],
         "event_triggers": SensorData["event_triggers"]
        }
    data = json.dumps(d).encode("utf-8")
    headers = {'Authorization':auth,
          'AW-Tenant-Code':settings["APIKey"],
          'Accept':'application/json;version=2',
          'Content-Type': 'application/json'}

    try:
        oslog("Assigning Sensor...")
    	req = urllib2.Request(url=url, data=data, headers=headers)
    	resp = urllib2.urlopen(req).read()
    	AssignmentJSON = json.loads(resp)
        oslog("Sensor successfully assigned: " + AssignmentJSON["uuid"])
        return AssignmentJSON
    except Exception as err:
        oslog(err)


def createFolder(path):
    if not os.path.exists(path):
        os.makedirs(path)

def main():
    
    #setup
    with open('settings.conf') as data_file:    
        settings = json.load(data_file)

    auth = getAuth(settings["Username"], settings["Password"])

    createFolder(sensorpath)
    
    option = -1
    while option != 0:
        print("")
        print("Select operation")
        print("1: Get Custom Attribute Profiles from Source Tenant")
        print("2: Upload Sensors to Destination Tenant")
        print("0: Exit")
        print("")

        option = input()
        option = int(option)
        
        if option == 1:
            oslog("Fetching Custom Attribute profiles...")
            getCAProfiles(auth, settings)
        elif option == 2:
            oslog("Uploading Sensors...")
            uploadSensors(auth, settings)
        elif option == 0:
            oslog("exiting.....")
            os._exit(os.EX_OK)


if __name__ == '__main__':
    main()