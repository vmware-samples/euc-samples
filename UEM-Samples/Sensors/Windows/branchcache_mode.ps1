# Returns branchcache Client Configuration mode being used by the device
# Return Type: String
# Execution Context: User
$branchcache = Get-BCClientConfiguration
write-output $branchcache.CurrentClientMode