$watcher = New-Object System.IO.FileSystemWatcher "C:\Test", "*.*"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true
Register-ObjectEvent $watcher "Created" -Action { Write-Host "File created: $($Event.SourceEventArgs.Name)" }