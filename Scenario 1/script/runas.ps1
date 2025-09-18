# $Username = "DESKTOP-A374OCC\P5yDuck"
# $Password = ConvertTo-SecureString "Zombies505" -AsPlainText -Force
# $Cred = New-Object System.Management.Automation.PSCredential ($Username, $Password)
# Start-Process powershell.exe -Credential $Cred -WorkingDirectory "C:\Windows\System32" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"&whoami`""
# Credentials
$Username = "DESKTOP-A374OCC\P5yDuck"
$Password = ConvertTo-SecureString "Zombies505" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($Username, $Password)

# Ask user for the command
$UserCommand = Read-Host "Enter the command run"

# Start PowerShell as P5yDuck and run the input command
Start-Process powershell.exe -Credential $Cred -WorkingDirectory "C:\Windows\System32" `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"& { $UserCommand }`"" -Wait
