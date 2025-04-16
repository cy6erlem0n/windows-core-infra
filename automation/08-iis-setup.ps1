# 08-iis-setup.ps1

. "$PSScriptRoot\..\config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()
if ($hostname -ne $PrimaryHostname.ToUpper()) {
    Write-Error "This script must be run on $PrimaryHostname"
    exit 1
}

if (-not (Get-WindowsFeature -Name Web-Server).Installed) {
    Install-WindowsFeature -Name Web-Server | Out-Null
    Write-Host "IIS installed."
} else {
    Write-Host "IIS already installed."
}

if (!(Test-Path $IISSitePath)) {
    New-Item -Path $IISSitePath -ItemType Directory | Out-Null
    Write-Host "IIS site path created at $IISSitePath"
} else {
    Write-Host "IIS site path already exists."
}

$localIndex = "$PSScriptRoot\..\common\index.html"
if (Test-Path $localIndex) {
    Copy-Item $localIndex -Destination "$IISSitePath\index.html" -Force
    Write-Host "Custom index.html deployed."
} else {
    Write-Warning "Template index.html not found: $localIndex"
}

Start-Service W3SVC

Write-Host "IIS setup complete. Access via http://${PrimaryIP}:${IISSitePort}"
