# Description: Returns Java Version e.g. 8.0.1910.12
# Execution Context: SYSTEM
# Execution Architecture: EITHER_64BIT_OR_32BIT
# Return Type: STRING

$javaver=(Get-Command java -ErrorVariable err -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version)

if ($err.Count -eq 0) {
  $javaver = $javaver.ToString()
}
else
{
 $javaver = "JAVA not found"
}

Return $javaver.ToString()

