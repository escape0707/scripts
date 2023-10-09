$programVersionTag = "v0.7"
$githubReleaseUrl = "https://github.com/ililim/dual-key-remap/releases/download/$programVersionTag/dual-key-remap-$programVersionTag.zip"
$zipPath = [System.IO.Path]::Combine($env:TEMP, "dual-key-remap-$programVersionTag.zip")
Invoke-WebRequest -Uri $githubReleaseUrl -OutFile $zipPath

$extractDir = [System.IO.Path]::Combine($env:USERPROFILE, "my-programs", "dual-key-remap")
Expand-Archive -Path $zipPath -DestinationPath $extractDir
Remove-Item $zipPath

$programDir = [System.IO.Path]::Combine($extractDir, "dual-key-remap-$programVersionTag")
$programPath = [System.IO.Path]::Combine($programDir, "dual-key-remap.exe")
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
    -Name "dual-key-remap" `
    -Value $programPath

$configPath = [System.IO.Path]::Combine($programDir, "config.txt")
(Get-Content $configPath) -replace "CAPSLOCK", "ESCAPE" | Set-Content $configPath

$scanCodeMap = [byte[]]@(0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x03,0x00,0x00, `
    0x00,0x01,0x00,0x3a,0x00,0x3a,0x00,0x01,0x00,0x00,0x00,0x00,0x00)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout" `
    -Name "Scancode Map" `
    -Value $scanCodeMap
