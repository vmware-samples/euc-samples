# Description: Return / Create and return random number used to create Deployment Rings
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: INTEGER

$value = Get-Random -Minimum 1 -Maximum 10
$name = "DeploymentRing"
$key = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Airwatch"
if(Get-ItemProperty -Path $key -Name $name -ErrorAction Ignore) {
  $returnvalue = (Get-ItemProperty -Path $key -Name $name).$name
} else {
  New-ItemProperty -Path $key -Name $name -PropertyType DWORD -Value $value -ErrorAction SilentlyContinue -Force
  sleep 1
  $returnvalue = (Get-ItemProperty -Path $key -Name $name).$name
}

return $returnvalue

