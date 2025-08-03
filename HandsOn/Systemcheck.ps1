Get-CimInstance Win32_Processor | Select-Object LoadPercentage
Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | 
Select-Object DeviceID, @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}}