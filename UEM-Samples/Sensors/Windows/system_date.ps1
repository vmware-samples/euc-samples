# Description: Returns the system's date and time in the format YYYY-MM-DDT<24hrTime>
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: DATETIME

$date_current = get-Date -format s -DisplayHint Date
Return $date_current

