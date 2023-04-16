# Returns the system's date and time
# Return Type: DateTime
# Execution Context: User
$date_current = get-Date -format s -DisplayHint Date
write-output $date_current
