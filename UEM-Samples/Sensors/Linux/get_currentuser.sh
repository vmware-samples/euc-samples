#!/bin/bash

# Get the current terminal
#terminal=$(tty)

# Get the username of the user logged into the terminal
#user=$(who $terminal | cut -d ' ' -f 1)
user=$(who -m | cut -d ' ' -f 1)

# Print the username
echo $user

# Description: Returns the current logged on user
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING
# Platform: LINUX