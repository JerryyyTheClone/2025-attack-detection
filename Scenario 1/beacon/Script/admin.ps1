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

$lowPrivUser = "it-admin"
$lowPrivPassword = "123456@xX"

Write-Output "[*] Creating user '$lowPrivUser'..."
net user $lowPrivUser $lowPrivPassword /add
Add-LocalGroupMember -Group "Administrators" -Member $lowPrivUser


# === 3. Enable SMB Server ===
Write-Output "[*] Enabling SMB1 Protocol..."
Enable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart -ErrorAction SilentlyContinue

# === 3. Enable SMB Server and create share ===
Write-Output "[*] Starting required services for SMB..."
Start-Service -Name "LanmanServer" -ErrorAction SilentlyContinue
Set-Service -Name "LanmanServer" -StartupType Automatic
Set-NetFirewallRule -DisplayGroup "File and Printer Sharing" -Enabled True


Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Start-Service -Name TermService
Set-Service -Name TermService -StartupType Automatic

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

Write-Output "[*] Enabling Print Spooler service..."
Set-Service -Name "Spooler" -StartupType Automatic
Start-Service -Name "Spooler" -ErrorAction SilentlyContinue

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# === Done ===
Write-Output "`n[✓] Lab setup completed successfully. You can now test privilege escalation exploits."
Write-Output "[!] Login with '$lowPrivUser' and try exploiting SeImpersonatePrivilege with PrintSpoofer or RoguePotato."