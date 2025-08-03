# -----------------------------------------------
# CONFIGURATION
# -----------------------------------------------
$installerPath = "C:\Installers\chrome_installer.exe"   # Path to local installer
$remoteInstallerPath = "C$\Temp\chrome_installer.exe"   # Remote location to copy
$silentArgs = "/silent /install"                        # Installer silent flags
$computerList = @("PC1", "PC2", "PC3")         # Add computer names/IPs
$logFile = "C:\InstallLogs\Install_Report_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"

# -----------------------------------------------
# Ensure log directory exists
# -----------------------------------------------
New-Item -Path (Split-Path $logFile) -ItemType Directory -Force | Out-Null

# -----------------------------------------------
# Begin installation loop
# -----------------------------------------------
foreach ($computer in $computerList) {
    Write-Host "`n➡️  Connecting to $computer..." -ForegroundColor Cyan
    $logEntry = "`n====================`nComputer: $computer`nTime: $(Get-Date)`n"

    try {
        # Test connectivity
        if (-not (Test-Connection -ComputerName $computer -Count 1 -Quiet)) {
            throw "❌ $computer is not reachable"
        }

        # Copy installer to remote machine
        $dest = "\\$computer\$remoteInstallerPath"
        $destFolder = Split-Path $dest
        if (-not (Test-Path $destFolder)) {
            New-Item -Path $destFolder -ItemType Directory -Force | Out-Null
        }
        Copy-Item -Path $installerPath -Destination $dest -Force

        # Run installer silently via Invoke-Command
        $remoteCommand = {
            Start-Process -FilePath "C:\Temp\chrome_installer.exe" -ArgumentList "/silent /install" -Wait -NoNewWindow
        }

        Invoke-Command -ComputerName $computer -ScriptBlock $remoteCommand

        $logEntry += "✅ Installation successful."
        Write-Host "✅ Installed on $computer" -ForegroundColor Green
    }
    catch {
        $logEntry += "❌ Error: $_"
        Write-Host "❌ Failed on $computer - $_" -ForegroundColor Red
    }

    # Write result to log
    $logEntry | Out-File -FilePath $logFile -Append
}

Write-Host "`n📝 Full log saved at: $logFile" -ForegroundColor Yellow
