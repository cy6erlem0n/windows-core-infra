# 10-replication-robocopy-secondary.ps1

New-Item -Path "C:\ReplicationData" -ItemType Directory -Force

New-SmbShare -Name "ReplicationDataShare" -Path "C:\ReplicationData" -FullAccess "Everyone"

Write-Host "ReplicationDataShare prepared on SRV-CORE2"

