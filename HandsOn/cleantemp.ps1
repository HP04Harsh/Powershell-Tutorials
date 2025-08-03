$temp = "$env:TEMP\*"
$deleted = Get-ChildItem $temp -Recurse | Remove-Item -Force -Verbose