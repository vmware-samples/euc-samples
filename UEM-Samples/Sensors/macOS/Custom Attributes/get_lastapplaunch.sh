# To format as "yyyy-mm-dd hh.MM.ss +####" 
#!/bin/bash

filePath="/Applications/Firefox.app"

lastLaunch=$(mdls -name kMDItemLastUsedDate -raw "$filePath")
echo "$lastLaunch" | tr : .

# To format as "yyyy-mm-dd hh.MM.ss" (GMT)
#!/bin/bash

filePath="/Applications/Firefox.app"

lastLaunch=$(mdls -name kMDItemLastUsedDate -raw "$filePath")
echo "${lastLaunch::19}" | tr : .
# To format as "yyyy-mm-dd"
#!/bin/bash

filePath="/Applications/Firefox.app"

lastLaunch=$(mdls -name kMDItemLastUsedDate -raw "$filePath")
echo "${lastLaunch::10}" | tr : .

# Description: Used to determine the last time a particular app was launched.  Make sure to update the "filePath=" line to match the pasth of the app in question. Multiple examples using Firefox as the app.
# Execution Context: SYSTEM
# Execution Architecture: UNKNOWN
# Return Type: STRING