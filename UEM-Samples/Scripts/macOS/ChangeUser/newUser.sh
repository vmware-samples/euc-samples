#!/bin/bash

# Change user working path
workingPath="/Library/VMware/WS1/changeUser"

# Create working path
mkdir -p $workingPath 

# Log file name
logFile="$workingPath/changeUser.log"

# Old user file name
oldUserFile="$workingPath/changeUser.old"

# New user file name
newUserFile="$workingPath/changeUser.new"

# Current date/time
dateCurrent=$(date '+%Y-%m-%d %I:%M:%S')

# Create log event
logEvent="[${dateCurrent}] [newUser]"

# Create the log file
touch $logFile

# Open permissions to account for all error catching
chmod 666 $logFile

# Begin Logging
echo "${logEvent} Initializing script" >> $logFile

# Ensures that the system is not domain bound
readonly domainBoundCheck=$(dsconfigad -show)

if [[ "${domainBoundCheck}" ]]; then

	echo "${logEvent} Error: Cannot run on domain bound system. Unbind system and try again." >> $logFile
	
else

	if [ ! -f "$oldUserFile" ]; then
	
		echo "${logEvent} $oldUserFile not found" >> $logFile
		echo "FAILURE"
				
	else
	
		if [ ! -f "$newUserFile" ]; then
		
    			echo "${logEvent} $newUserFile not found" >> $logFile
    			echo "FAILURE"
    		
    		else
    		
    			oldUser=`/bin/cat $oldUserFile`
			newUser=`/bin/cat $newUserFile`

			# Test to ensure logged in user is not being renamed
			readonly loggedInUser=$(ls -la /dev/console | cut -d " " -f 4)
    		
    			# Verify valid usernames
			if [[ -z "${newUser}" ]]; then
			
				echo "${logEvent} Error: New user name must not be empty!" >> $logFile
				echo "FAILURE"
				
			else
			
				# Test to ensure account update is needed
				if [[ "${oldUser}" == "${newUser}" ]]; then
				
					echo "${logEvent} Error: Account ${oldUser}" is the same name "${newUser}" >> $logFile
					echo "FAILURE"
					
				else
				
					# Query existing user accounts
					readonly existingUsers=($(dscl . -list /Users | grep -Ev "^_|com.*|root|nobody|daemon|\/" | cut -d, -f1 | sed 's|CN=||g'))
					
					# Ensure old user account is correct and account exists on system
					if [[ ! " ${existingUsers[@]} " =~ " ${oldUser} " ]]; then
					
						echo "${logEvent} Error: ${oldUser} account not present on system to update" >> $logFile
						echo "FAILURE"
						
					else
					
						# Ensure new user account is not already in use
						if [[ " ${existingUsers[@]} " =~ " ${newUser} " ]]; then
						
							echo "${logEvent} Error: ${newUser} account already present on system. Cannot add duplicate" >> $logFile
							echo "FAILURE"
							
						else
						
							# Query existing home folders
							readonly existingHomeFolders=($(ls /Users))
						
							# Ensure existing home folder is not in use
							if [[ " ${existingHomeFolders[@]} " =~ " ${newUser} " ]]; then
							
								echo "${logEvent} Error: ${newUser} home folder already in use on system. Cannot add duplicate" >> $logFile
								echo "FAILURE"
								
							else
							
								# Check if username differs from home directory name
								actual=$(eval echo "~${oldUser}")
							
								if [[ "/Users/${oldUser}" != "$actual" ]]; then
								
									echo "${logEvent} Error: Username differs from home directory name!" >> $logFile
									echo "${logEvent} Error: home directory: ${actual} should be: /Users/${oldUser}, aborting." >> $logFile
									echo "FAILURE"
									
								else
								
									# Captures current NFS home directory
									readonly origHomeDir=$(dscl . -read "/Users/${oldUser}" NFSHomeDirectory | awk '{print $2}' -)
									
									if [[ -z "${origHomeDir}" ]]; then
									
										echo "${logEvent} Error: Cannot obtain the original home directory name, is the ${oldUser} name correct?" >> $logFile
										echo "FAILURE"
									
									else
									
										# Updates name of home directory to new username
										mv "${origHomeDir}" "/Users/${newUser}"
										
										if [[ $? -ne 0 ]]; then
										
											echo "${logEvent} Error: Could not rename the user's home directory in /Users" >> $logFile
											echo "${logEvent} Notice: Reverting Home Directory changes" >> $logFile
											mv "/Users/${newUser}" "${origHomeDir}"
											dscl . -change "/Users/${oldUser}" NFSHomeDirectory "/Users/${newUser}" "${origHomeDir}"
											echo "FAILURE"
											
										else
										
											# Actual username change
											dscl . -change "/Users/${oldUser}" RecordName "${oldUser}" "${newUser}"
										
											if [[ $? -ne 0 ]]; then
											
												echo "${logEvent} Error: Could not rename the user's RecordName in dscl - the user should still be able to login, but with user name ${oldUser}" >> $logFile
												echo "${logEvent} Notice: Reverting username change" >> $logFile
												dscl . -change "/Users/${oldUser}" RecordName "${newUser}" "${oldUser}"
												echo "${logEvent} Notice: Reverting Home Directory changes" >> $logFile
												mv "/Users/${newUser}" "${origHomeDir}"
												dscl . -change "/Users/${oldUser}" NFSHomeDirectory "/Users/${newUser}" "${origHomeDir}"
												echo "FAILURE"
												
											else
											
												# Links old home directory to new. Fixes dock mapping issue
												ln -s "/Users/${newUser}" "${origHomeDir}"

												echo $newUser
											
											fi
											
										fi
										
									fi
									
								fi
							
							fi
						
						fi
					
					fi
					
				fi
			
			fi
    		
		fi
	
	fi

fi
