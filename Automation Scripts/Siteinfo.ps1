# Install-Module PnP.PowerShell -Scope CurrentUser -Force (Install this Powershell 7.0)
# Requires PowerShell 7+ and PnP.PowerShell
# Install-Module PnP.PowerShell -Scope CurrentUser -Force

Clear-Host
Write-Host "🔐 SharePoint Site Info Gatherer" -ForegroundColor Cyan

# Admin URL and Site URL prompts
$adminUrl = Read-Host "`nEnter your SharePoint Admin Center URL (e.g. https://yourtenant-admin.sharepoint.com)"
$siteUrl = Read-Host "Enter the SharePoint Site URL (e.g. https://yourtenant.sharepoint.com/sites/yoursite)"

# Step 1: Connect using Connect-PnPOnline
Write-Host "`n🔄 Connecting to SharePoint..." -ForegroundColor Yellow
try {
    Connect-PnPOnline -Url $adminUrl -Interactive -ErrorAction Stop
    Write-Host "✅ Connected to SharePoint Admin Center" -ForegroundColor Green
}
catch {
    Write-Error "❌ Failed to connect. $_"
    exit
}

# Step 2: Get Site Info from the tenant
try {
    $site = Get-PnPTenantSite -Url $siteUrl -ErrorAction Stop
}
catch {
    Write-Error "❌ Site not found or insufficient permissions. $_"
    exit
}

# Step 3: Get Site Collection Admins
try {
    $admins = Get-PnPSiteCollectionAdmin -Url $siteUrl
}
catch {
    Write-Warning "⚠ Could not fetch site collection admins. Trying fallback connection..."
    Connect-PnPOnline -Url $siteUrl -Interactive
    $admins = Get-PnPSiteCollectionAdmin
}

# Step 4: Show Results
Write-Host "`n📄 Site Information" -ForegroundColor Cyan
Write-Host "Title        : $($site.Title)"
Write-Host "URL          : $($site.Url)"
Write-Host "Template     : $($site.Template)"
Write-Host "Owner        : $($site.Owner)"
Write-Host "Storage Used : $([math]::Round($site.StorageUsageCurrent / 1024, 2)) MB"
Write-Host "Quota        : $([math]::Round($site.StorageMaximumLevel / 1024, 2)) MB"
Write-Host "Last Modified: $($site.LastContentModifiedDate)"
Write-Host "Sharing      : $($site.SharingCapability)"

Write-Host "`n👤 Site Collection Admin(s):"
$admins | Select-Object LoginName, Email, IsSiteAdmin | Format-Table -AutoSize

# Optional CSV export
$save = Read-Host "`n💾 Do you want to export this info to CSV? (y/n)"
if ($save -eq 'y') {
    $csvPath = "$env:USERPROFILE\Desktop\SharePointSiteInfo_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $exportObj = [PSCustomObject]@{
        Title        = $site.Title
        URL          = $site.Url
        Template     = $site.Template
        Owner        = $site.Owner
        StorageUsedMB = [math]::Round($site.StorageUsageCurrent / 1024, 2)
        QuotaMB       = [math]::Round($site.StorageMaximumLevel / 1024, 2)
        LastModified  = $site.LastContentModifiedDate
        Sharing       = $site.SharingCapability
        Admins        = ($admins.LoginName -join "; ")
    }
    $exportObj | Export-Csv -Path $csvPath -NoTypeInformation
    Write-Host "✅ Exported to: $csvPath" -ForegroundColor Green
}

Disconnect-PnPOnline
