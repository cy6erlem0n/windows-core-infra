# 10-replication-robocopy-primary.ps1

. "$PSScriptRoot\..\config.ps1"

$ReplicationPath = "C:\ReplicationData"
$ShareName = "ReplicationDataShare"
$RemotePath = "\\$SecondaryHostname\$ShareName"
$RobocopyScriptPath = "C:\Scripts\RunRobocopy.ps1"

Write-Host "[REPLICATION] Creating replication folder and SMB share on primary server..."
New-Item -Path $ReplicationPath -ItemType Directory -Force | Out-Null
New-SmbShare -Name $ShareName -Path $ReplicationPath -FullAccess "Everyone"

Write-Host "[REPLICATION] Generating robocopy script..."

$robocopyScript = @"
Robocopy "$ReplicationPath" "$RemotePath" /MIR /Z /R:3 /W:5 /NP /LOG:C:\replication_log.txt
"@

New-Item -Path "C:\Scripts" -ItemType Directory -Force | Out-Null
$robocopyScript | Set-Content -Path $RobocopyScriptPath

Write-Host "[REPLICATION] Creating daily scheduled task to run robocopy..."
schtasks /Create /SC DAILY /TN "RobocopyReplicationDaily" /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File $RobocopyScriptPath" /ST 23:00 /RU SYSTEM | Out-Null

Write-Host "[REPLICATION] Task created. You can verify it with schtasks /Query /TN RobocopyReplicationDaily /V"
