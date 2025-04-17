# 10-replication-robocopy-secondary.ps1

. "$PSScriptRoot\00-config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()
if ($hostname -ne $SecondaryHostname.ToUpper()) {
    Write-Error "This script must be run on $SecondaryHostname"
    exit 1
}

$replicationPath = "C:\ReplicationData"
$shareName = "ReplicationDataShare"

if (!(Test-Path $replicationPath)) {
    New-Item -Path $replicationPath -ItemType Directory -Force | Out-Null
    Write-Host "Directory created at $replicationPath"
} else {
    Write-Host "Directory already exists at $replicationPath"
}

if (-not (Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name $shareName -Path $replicationPath -FullAccess "Everyone" | Out-Null
    Write-Host "SMB share '$shareName' created."
} else {
    Write-Host "SMB share '$shareName' already exists."
}

Write-Host "ReplicationDataShare prepared on $SecondaryHostname"
