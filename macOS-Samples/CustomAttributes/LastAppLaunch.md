# Last App Launch

* Author: Paul Evans
* Email: pevans@vmware.com
* Date Created: 7/29/2019
* Supported Platforms: WS1 UEM 1907
* Tested on macOS Versions: macOS Mojave

This custom attribute can be used to determine the last time a particular app was launched.  Make sure to update the "filePath=" line to match the pasth of the app in question.

### To format as "yyyy-mm-dd hh.MM.ss +####" 
```bash
#!/bin/bash

filePath="/Applications/Firefox.app"

lastLaunch=$(mdls -name kMDItemLastUsedDate -raw "$filePath")
echo "$lastLaunch" | tr : .
```

### To format as "yyyy-mm-dd hh.MM.ss" (GMT)
```bash
#!/bin/bash

filePath="/Applications/Firefox.app"

lastLaunch=$(mdls -name kMDItemLastUsedDate -raw "$filePath")
echo "${lastLaunch::19}" | tr : .
```

### To format as "yyyy-mm-dd"

```bash
#!/bin/bash

filePath="/Applications/Firefox.app"

lastLaunch=$(mdls -name kMDItemLastUsedDate -raw "$filePath")
echo "${lastLaunch::10}" | tr : .
```