Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | 
Select-Object DeviceID, @{Name="Size(GB)";Expression={[math]::Round($_.Size/1GB,2)}}, @{Name="Free(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}} |
Export-Csv disk_report.csv -NoTypeInformation