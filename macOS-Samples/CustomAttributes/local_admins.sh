#!/bin/bash

admins=$(/usr/bin/dscl . -read /Groups/admin GroupMembership | /usr/bin/cut -c 18-)

echo $admins