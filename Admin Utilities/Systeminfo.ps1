# Load Windows Forms for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---- Create GUI Form ----
$form = New-Object System.Windows.Forms.Form
$form.Text = "System Report Generator"
$form.Size = New-Object System.Drawing.Size(420, 280)
$form.StartPosition = "CenterScreen"

# Instructions Label
$label = New-Object System.Windows.Forms.Label
$label.Text = "Click the button to generate a system report"
$label.Size = New-Object System.Drawing.Size(380, 30)
$label.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($label)

# Status Label
$status = New-Object System.Windows.Forms.Label
$status.Text = ""
$status.Size = New-Object System.Drawing.Size(360, 60)
$status.Location = New-Object System.Drawing.Point(20, 140)
$form.Controls.Add($status)

# Save Location Button
$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Text = "Choose Save Location"
$saveButton.Size = New-Object System.Drawing.Size(180, 30)
$saveButton.Location = New-Object System.Drawing.Point(110, 60)
$form.Controls.Add($saveButton)

# Default Save Path
$global:savePath = "$env:USERPROFILE\Desktop\System_Report.txt"

$saveButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    $dialog.Filter = "Text Files (*.txt)|*.txt|Excel Files (*.xlsx)|*.xlsx"
    $dialog.FileName = "System_Report.txt"
    if ($dialog.ShowDialog() -eq "OK") {
        $global:savePath = $dialog.FileName
        $status.Text = "Save path set to:`n$global:savePath"
    }
})

# Generate Report Button
$generateBtn = New-Object System.Windows.Forms.Button
$generateBtn.Text = "Generate Report"
$generateBtn.Size = New-Object System.Drawing.Size(180, 40)
$generateBtn.Location = New-Object System.Drawing.Point(110, 100)
$form.Controls.Add($generateBtn)

$generateBtn.Add_Click({

    $status.Text = "Collecting system info..."

    # ----- Gather System Information -----

    # CPU
    $cpu = Get-WmiObject Win32_Processor | Select-Object Name, LoadPercentage

    # Memory
    $os = Get-WmiObject Win32_OperatingSystem
    $totalMem = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeMem = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedMem = [math]::Round($totalMem - $freeMem, 2)

    # Disks
    $disks = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"

    # Users
    $users = quser 2>&1

    # Logs
    $logs = Get-EventLog -LogName Security -Newest 10 | Select-Object TimeGenerated, EntryType, Source, Message

    # ---- Format as human-readable text ----

    $report = @"
=======================
  SYSTEM REPORT
  Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
=======================

[CPU Information]
"@

    foreach ($c in $cpu) {
        $report += "CPU Name     : $($c.Name)`n"
        $report += "CPU Load %   : $($c.LoadPercentage)`n"
    }

    $report += @"

[Memory Usage]
Total Memory : $totalMem MB
Used Memory  : $usedMem MB
Free Memory  : $freeMem MB

[Disk Usage]
"@

    foreach ($d in $disks) {
        $drive = $d.DeviceID
        $free = [math]::Round($d.FreeSpace / 1GB, 2)
        $total = [math]::Round($d.Size / 1GB, 2)
        $report += "Drive $drive : $free GB free of $total GB`n"
    }

    $report += @"

[Logged-in Users]
$users

[Recent Security Logs]
"@

    foreach ($log in $logs) {
        $msg = $log.Message -replace "`r?`n", " "
        $report += "[$($log.TimeGenerated)] $($log.EntryType) - $($log.Source): $msg`n"
    }

    # ---- Save to File (.txt or Excel) ----

    if ($savePath -like "*.txt") {
        $report | Out-File -FilePath $savePath -Encoding UTF8
    }
    elseif ($savePath -like "*.xlsx") {
        # Requires ImportExcel module
        if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
            Install-Module ImportExcel -Scope CurrentUser -Force
        }

        $data = [PSCustomObject]@{
            CPU_Name      = $cpu[0].Name
            CPU_Load      = $cpu[0].LoadPercentage
            Total_Memory  = "$totalMem MB"
            Used_Memory   = "$usedMem MB"
            Free_Memory   = "$freeMem MB"
            Logged_Users  = $users -join "`n"
        }

        $data | Export-Excel -Path $savePath -AutoSize -WorksheetName "System Info"
    }

    $status.Text = "✅ Report saved to:`n$savePath"
})

# Show Form
[void]$form.ShowDialog()
