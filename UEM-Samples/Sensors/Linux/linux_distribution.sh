( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1
# Description: Return the Linux Distro Name
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING
# Platform: LINUX
