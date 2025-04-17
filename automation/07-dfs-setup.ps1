# 07-dfs-setup.ps1

. "$PSScriptRoot\00-config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()
if ($hostname -ne $PrimaryHostname.ToUpper()) {
    Write-Error "This script must be run on $PrimaryHostname"
    exit 1
}

if (!(Test-Path $SharedFolderPath)) {
    New-Item -Path $SharedFolderPath -ItemType Directory | Out-Null
    Write-Host "Shared folder created at $SharedFolderPath"
} else {
    Write-Host "Shared folder already exists at $SharedFolderPath"
}

if (-not (Get-SmbShare -Name "SharedFolder" -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name "SharedFolder" -Path $SharedFolderPath -FullAccess "Everyone"
    Write-Host "SMB share 'SharedFolder' created."
} else {
    Write-Host "SMB share 'SharedFolder' already exists."
}

if (-not (Get-DfsnRoot -Path "\\$DomainName\$NamespaceName" -ErrorAction SilentlyContinue)) {
    New-DfsnRoot -TargetPath "\\$PrimaryHostname\SharedFolder" -Path "\\$DomainName\$NamespaceName" -Type DomainV2
    Write-Host "DFS namespace root created."
} else {
    Write-Host "DFS namespace root already exists."
}

if (-not (Get-DfsnFolder -Path "\\$DomainName\$NamespaceName\Docs" -ErrorAction SilentlyContinue)) {
    New-DfsnFolder -Path "\\$DomainName\$NamespaceName\Docs" -TargetPath "\\$PrimaryHostname\SharedFolder"
    Write-Host "DFS folder 'Docs' created."
} else {
    Write-Host "DFS folder 'Docs' already exists."
}

$quotaScript = "$PSScriptRoot\common\Set-FsrmQuota.ps1"
if (Test-Path $quotaScript) {
    PowerShell -ExecutionPolicy Bypass -File $quotaScript
    Write-Host "Quota script executed."
} else {
    Write-Warning "Quota script not found: $quotaScript"
}
