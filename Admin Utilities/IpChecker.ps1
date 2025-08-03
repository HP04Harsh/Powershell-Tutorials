# PowerShell Script to get server details from a URL

param (
    [string]$url = "www.google.com"
)

# Ensure the URL doesn't include scheme
$url = $url -replace "^https?://", ""

Write-Host "`n🔎 Fetching server info for: $url`n" -ForegroundColor Cyan

# 1. Resolve DNS to IP address
try {
    $ips = [System.Net.Dns]::GetHostAddresses($url)
    Write-Host "📍 IP Address(es):"
    $ips | ForEach-Object { Write-Host "  - $_" }
}
catch {
    Write-Host "❌ Could not resolve IP address." -ForegroundColor Red
    exit
}

# 2. Ping test
Write-Host "`n📡 Pinging server..."
ping $url -n 2 | Out-Host

# 3. Web request to get response headers
try {
    $response = Invoke-WebRequest -Uri "https://$url" -Method Head -UseBasicParsing
    Write-Host "`n📦 Server Headers:"
    $response.Headers.GetEnumerator() | ForEach-Object {
        Write-Host "  $_"
    }
}
catch {
    Write-Host "⚠️ Unable to get server headers (maybe HTTPS block or redirect)." -ForegroundColor Yellow
}

# 4. Use IP Geolocation API (ipinfo.io)
foreach ($ip in $ips) {
    $api = "https://ipinfo.io/$ip/json"
    try {
        $geo = Invoke-RestMethod -Uri $api
        Write-Host "`n🌍 Geolocation Info for $ip"
        Write-Host "  IP       : $($geo.ip)"
        Write-Host "  Country  : $($geo.country)"
        Write-Host "  Region   : $($geo.region)"
        Write-Host "  City     : $($geo.city)"
        Write-Host "  Org      : $($geo.org)"
        Write-Host "  Location : $($geo.loc)"
        Write-Host "  Timezone : $($geo.timezone)"
    }
    catch {
        Write-Host "⚠️ Failed to fetch geolocation for $ip" -ForegroundColor Yellow
    }
}

Write-Host "`n✅ Done.`n" -ForegroundColor Green
