# Returns the average amount of non-paged and paged memory that the process is using, in kilobytes.
# Return Type: Integer
# Execution Context: User
# change TaskScheduler to your process name

$PM = get-process TaskScheduler |Measure-object -property PM -Average -ErrorVariable err -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Average
$NPM = get-process TaskScheduler |Measure-object -property NPM -Average -ErrorVariable err -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Average
$memory = [System.Math]::Round(($PM+$NPM)/1KB)
write-output ([System.Math]::Round($memory))