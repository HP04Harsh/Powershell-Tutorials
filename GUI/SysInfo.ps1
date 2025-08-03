Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "🖥 System Info Panel"
$form.Size = New-Object System.Drawing.Size(600, 450)
$form.StartPosition = "CenterScreen"

# Output Textbox
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Multiline = $true
$outputBox.ReadOnly = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.Size = New-Object System.Drawing.Size(560, 250)
$outputBox.Location = New-Object System.Drawing.Point(10, 150)
$form.Controls.Add($outputBox)

# Button Creator Function
function Add-Button {
    param($text, $location, $onClick)
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size(130, 30)
    $btn.Location = $location
    $btn.Add_Click($onClick)
    $form.Controls.Add($btn)
}

# CPU Info
Add-Button "🧠 CPU Info" (New-Object Drawing.Point(10, 20)) {
    $cpu = Get-CimInstance Win32_Processor
    $outputBox.Text = "CPU Name: $($cpu.Name)`nCores: $($cpu.NumberOfCores)`nArchitecture: $($cpu.AddressWidth)-bit"
}

# RAM Info
Add-Button "💾 RAM Info" (New-Object Drawing.Point(150, 20)) {
    $mem = Get-CimInstance Win32_OperatingSystem
    $total = [math]::Round($mem.TotalVisibleMemorySize / 1MB, 2)
    $free = [math]::Round($mem.FreePhysicalMemory / 1MB, 2)
    $outputBox.Text = "Total RAM: $total GB`nFree RAM: $free GB"
}

# Disk Info
Add-Button "🗂 Disk Info" (New-Object Drawing.Point(290, 20)) {
    $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
    $out = ""
    foreach ($disk in $disks) {
        $size = [math]::Round($disk.Size / 1GB, 2)
        $free = [math]::Round($disk.FreeSpace / 1GB, 2)
        $out += "Drive: $($disk.DeviceID)`nSize: $size GB`nFree: $free GB`n`n"
    }
    $outputBox.Text = $out
}

# OS Info
Add-Button "🪟 OS Info" (New-Object Drawing.Point(430, 20)) {
    $os = Get-CimInstance Win32_OperatingSystem
    $outputBox.Text = "OS: $($os.Caption)`nBuild: $($os.BuildNumber)`nUser: $($os.RegisteredUser)"
}

# IP Info
Add-Button "🌐 IP Info" (New-Object Drawing.Point(10, 70)) {
    $net = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "169.*"}
    $out = ""
    foreach ($n in $net) {
        $out += "Interface: $($n.InterfaceAlias)`nIP: $($n.IPAddress)`n`n"
    }
    $outputBox.Text = $out
}

# Show Form
[void]$form.ShowDialog()
