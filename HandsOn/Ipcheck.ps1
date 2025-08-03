$web = "www.google.com"
$ip = (Resolve-DnsName $web).IPAddress
$response = Invoke-RestMethod "http://ip-api.com/json/$ip"
$response | Format-List