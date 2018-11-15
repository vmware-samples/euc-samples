# Returns Java Version e.g. 8.0.1910.12
# Return Type: String
# Execution Context: User
$javaver=(Get-Command java | Select-Object -ExpandProperty Version).toString()
echo $javaver