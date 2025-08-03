# DailyCleanup.ps1 - Automates system cleanup and log backup

# ------------------ CONFIGURATION ------------------
$logFolder     = "C:\Logs"                           # Folder containing logs to archive
$cleanupLog    = "C:\CleanupReports\cleanup_log.txt" # Report path
$zipArchiveDir = "C:\ArchivedLogs"                   # Where to save archived ZIP files
$tempFolders   = @(
    "$env:TEMP",
    "$env:WINDIR\Temp",
    "$env:USERPROFILE\AppData\Local\Temp"
)
# ----------------------------------------------------

# Ensure folders exist
New-Item -ItemType Directory -Path (Split-Path $cleanupLog) -Force | Out-Null
New-Item -ItemType Directory -Path $zipArchiveDir -Force | Out-Null

$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$report = @()
$report += "==== DAILY CLEANUP REPORT ===="
$report += "Generated: $date`n"

# -------- Step 1: Delete Temp Files --------
$report += "🧹 Deleting Temp Files:"
foreach ($folder in $tempFolders) {
    if (Test-Path $folder) {
        $files = Get-ChildItem -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
        $count = $files.Count
        $files | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        $report += "  - $folder : Deleted $count items"
    }
}

# -------- Step 2: Empty Recycle Bin --------
$report += "`n🗑 Emptying Recycle Bin:"
try {
    Clear-RecycleBin -Force -ErrorAction Stop
    $report += "  - Recycle bin cleared."
} catch {
    $report += "  - Error clearing recycle bin: $_"
}

# -------- Step 3: Archive Logs --------
$report += "`n📦 Archiving logs from: $logFolder"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$zipFile = Join-Path $zipArchiveDir "Logs_$timestamp.zip"

if (Test-Path $logFolder) {
    try {
        Compress-Archive -Path "$logFolder\*" -DestinationPath $zipFile -Force
        $report += "  - Logs archived to $zipFile"
    } catch {
        $report += "  - Archiving failed: $_"
    }
} else {
    $report += "  - Log folder not found: $logFolder"
}

# -------- Step 4: Save Cleanup Log --------
$report += "`n✅ Cleanup Completed."

$reportText = $report -join "`r`n"
$reportText | Out-File -FilePath $cleanupLog -Append -Encoding UTF8

# Optional: Show report
Write-Host "`n$reportText" -ForegroundColor Green
