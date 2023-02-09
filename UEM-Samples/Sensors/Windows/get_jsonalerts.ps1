# Description: Returns various attributes from a JSON file
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$filepath = "C:\temp"
$hours = 6
#find Alert*.json files from last X hours. Time should match sensor run time, which is 6 hours by default
$AlertFiles = Get-ChildItem -Path ./* -Include "Alert*.json" | Where-Object {$_.LastWriteTime -gt (Get-Date).AddDays(-1)}
foreach ($afile in $AlertFiles){
  # Read XML document
  $json = Get-Content -Path $afile.FullName | Convertfrom-Json
  $value += ("{0}_{1}_{2}_{3}_{4}_{5}{6}" -f $json.Knumber,$json.Item,$json.State.Code,$json.State.Status,$json.State.Message,";")
}

return $value

