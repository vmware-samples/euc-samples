# Returns the average amount of non-paged and paged memory that the process is using, in kilobytes.
# Return Type: Integer
# Execution Context: User
# change mcshield to your process name
$PM = get-process mcshield |Measure-object -property PM -Average|Select-Object -ExpandProperty Average
$NPM = get-process mcshield |Measure-object -property NPM -Average|Select-Object -ExpandProperty Average
echo [System.Math]::Round(($PM+$NPM)/1KB)

