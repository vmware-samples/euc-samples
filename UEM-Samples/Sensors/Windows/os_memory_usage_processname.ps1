# Description: Returns the average amount of non-paged and paged memory that a defined process is using (in KB). Example returns usage for TaskScheduler.
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$PM = get-process TaskScheduler |Measure-object -property PM -Average -ErrorVariable err -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Average
$NPM = get-process TaskScheduler |Measure-object -property NPM -Average -ErrorVariable err -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Average
$memory = [System.Math]::Round(($PM+$NPM)/1MB)
Return "$memory MB"

