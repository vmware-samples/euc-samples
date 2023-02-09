IFS=';' read updates security_updates < <(/usr/lib/update-notifier/apt-check 2>&1)
echo $updates
# Description: Returns true if OS updates are available to the device
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: BOOLEAN
# Platform: LINUX
