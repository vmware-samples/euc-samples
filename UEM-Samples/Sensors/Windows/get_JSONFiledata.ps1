# Returns value from json file. Use this sensor to read a JSON file and return a value from a node
# Return Type: String
# Execution Context: System
# Execution Architecture: Auto

#Variables to modify
$filepath = "c:\temp"
$file = Get-ChildItem -Path $filepath -Include *.json -Recurse -Exclude *.json -ErrorAction SilentlyContinue

$json = Get-Content -Path $file.FullName | ConvertFrom-Json
$node = $json.state.status

if($node){return $node}else{return 0}