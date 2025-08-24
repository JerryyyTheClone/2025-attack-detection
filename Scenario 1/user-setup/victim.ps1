# === 1. Setup Administrator ===
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "You must run this script as Administrator!"
    exit
}

$SecurePassword = ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force

Write-Output "[*] Enabling built-in Administrator account..."
Enable-LocalUser -Name "Administrator" -ErrorAction SilentlyContinue

Write-Output "[*] Setting password for Administrator..."
Set-LocalUser -Name "Administrator" -Password $SecurePassword

# === 2. Enable SMB Server and create share ===
Write-Output "[*] Enabling SMB1 Protocol..."
Enable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart -ErrorAction SilentlyContinue
Write-Output "[*] Starting required services for SMB..."
Start-Service -Name "LanmanServer" -ErrorAction SilentlyContinue
Set-Service -Name "LanmanServer" -StartupType Automatic
Set-NetFirewallRule -DisplayGroup "File and Printer Sharing" -Enabled True
New-Item -ItemType Directory -Path "C:\SMBShare"
New-SmbShare -Name "Share01" -Path "C:\SMBShare" -FullAccess "Everyone"

# WinRm
$profiles = Get-NetConnectionProfile | Where-Object {$_.NetworkCategory -eq 'Public'}

foreach ($profile in $profiles) {
    Set-NetConnectionProfile -InterfaceIndex $profile.InterfaceIndex -NetworkCategory Private
    Write-Host "Changed interface $($profile.Name) to Private"
}

winrm quickconfig -quiet
Enable-PSRemoting -Force
Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any -Action Allow
Write-Host "`n[+] WinRM enabled and firewall opened on Private network."


# === 4. Create lowpriv user with SeImpersonatePrivilege ===
$lowPrivUser = "user1"
$lowPrivPassword = "qwerty@123"

Write-Output "[*] Creating user '$lowPrivUser'..."
net user $lowPrivUser $lowPrivPassword /add


Write-Output "[*] Enabling Print Spooler service..."
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v NoWarningNoElevationOnInstall /d 1 /t reg_dword
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /d 0 /t reg_dword
Set-Service -Name "Spooler" -StartupType Automatic
Start-Service -Name "Spooler" -ErrorAction SilentlyContinue
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# === 5. Enable RDP Service ===
Write-Output "[*] Enabling RDP service..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Start-Service -Name TermService -ErrorAction SilentlyContinue
Set-Service -Name TermService -StartupType Automatic
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fSingleSessionPerUser" -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "MaxInstanceCount" -Value 999999

# === 6. Sysmon ===
curl https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml > C:\Windows\sysmon-config.xml
.\Sysmon64.exe -accepteula -i C:\Windows\sysmon-config.xml


# === 7. Clear all log ===
Get-WinEvent -ListLog * -Force | ForEach-Object { wevtutil.exe cl $_.LogName }

# === Done ===
Write-Output "`nLab setup completed successfully. You can now test privilege escalation exploits."