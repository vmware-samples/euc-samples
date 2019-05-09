# Returns Java Version e.g. 8.0.1910.12
# Return Type: String
# Execution Context: User

$javaver=(Get-Command java -ErrorVariable err -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version)

if ($err.Count -eq 0) {
  $javaver = $javaver.ToString()
}
else
{
 $javaver = "JAVA not found"
}

write-output $javaver.ToString()