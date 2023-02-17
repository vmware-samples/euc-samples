ps -ef | grep sshd | grep -v "grep" | wc -l
# Description: Returns if SSHD running
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN
# Platform: LINUX
