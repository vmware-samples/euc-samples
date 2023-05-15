# Description: Check Windows Device Checkin in Carbon Black Cloud
# Execution Context: System
# Execution Architecture: EITHER64OR32BIT
# Timeout: 30

$found = 1
$CBcommand = "$Env:Programfiles\Confer\Repcli.exe"
$key = "Registered[Yes]"

if (Test-Path -LiteralPath $CBCommand) {
   $ExeOutput = & $CBcommand status | Out-String
   if ($ExeOutput.Contains("$key") ) {
      $found = 0
   }
}
# 0 sucessfull - anything else failure
Exit $found



