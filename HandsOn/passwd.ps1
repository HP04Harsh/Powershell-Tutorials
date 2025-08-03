Add-Type -AssemblyName System.Windows.Forms
$form = New-Object Windows.Forms.Form
$btn = New-Object Windows.Forms.Button
$btn.Text = "Generate Password"
$btn.Dock = "Fill"
$btn.Add_Click({ [System.Windows.Forms.MessageBox]::Show((1..12 | ForEach-Object { [char](Get-Random -Minimum 33 -Maximum 126) }) -join "") })
$form.Controls.Add($btn)
$form.ShowDialog()