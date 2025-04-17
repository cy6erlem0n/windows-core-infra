# 10-replication-robocopy-primary.ps1

. "$PSScriptRoot\00-config.ps1"

$ReplicationPath = "C:\ReplicationData"
$ShareName = "ReplicationDataShare"
$RemotePath = "\\$SecondaryHostname\$ShareName"
$RobocopyScriptPath = "C:\Scripts\RunRobocopy.ps1"
$TaskName = "RobocopyReplicationDaily"

Write-Host "[REPLICATION] Checking and creating replication folder..."
if (-not (Test-Path $ReplicationPath)) {
    New-Item -Path $ReplicationPath -ItemType Directory -Force | Out-Null
    Write-Host "[REPLICATION] Folder created at $ReplicationPath"
} else {
    Write-Host "[REPLICATION] Folder already exists at $ReplicationPath"
}

Write-Host "[REPLICATION] Checking and creating SMB share..."
if (-not (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name $ShareName -Path $ReplicationPath -FullAccess "Everyone"
    Write-Host "[REPLICATION] SMB share '$ShareName' created."
} else {
    Write-Host "[REPLICATION] SMB share '$ShareName' already exists."
}

Write-Host "[REPLICATION] Generating robocopy script..."
$robocopyScript = @"
Robocopy "$ReplicationPath" "$RemotePath" /MIR /Z /R:3 /W:5 /NP /LOG:C:\replication_log.txt
"@

New-Item -Path "C:\Scripts" -ItemType Directory -Force | Out-Null
$robocopyScript | Set-Content -Path $RobocopyScriptPath -Force

Write-Host "[REPLICATION] Checking if scheduled task '$TaskName' exists..."
schtasks /Query /TN $TaskName /FO LIST /V 2>$null | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "[REPLICATION] Task '$TaskName' already exists. Skipping creation."
} else {
    Write-Host "[REPLICATION] Task not found. Creating new scheduled task..."
    schtasks /Create /SC DAILY /TN $TaskName `
        /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$RobocopyScriptPath`"" `
        /ST 23:00 /RU SYSTEM | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[REPLICATION] Task '$TaskName' created successfully."
    } else {
        Write-Warning "[REPLICATION] Failed to create scheduled task '$TaskName'."
    }
}
