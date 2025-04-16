# 03b-promote-secondary.ps1

. "$PSScriptRoot\..\config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()

if ($hostname -ne $SecondaryHostname.ToUpper()) {
    Write-Error "This script must be run on $SecondaryHostname"
    exit 1
}

Write-Host "Promoting $hostname to additional Domain Controller in domain: $DomainName"

Install-ADDSDomainController `
    -DomainName $DomainName `
    -Credential (New-Object System.Management.Automation.PSCredential($AdminUser, $DomainAdminPassword)) `
    -InstallDns:$true `
    -Force
