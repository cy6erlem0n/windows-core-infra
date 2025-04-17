# 03b-promote-secondary.ps1

. "$PSScriptRoot\00-config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()

if ($hostname -ne $SecondaryHostname.ToUpper()) {
    Write-Error "This script must be run on $SecondaryHostname"
    exit 1
}

$domainRole = (Get-WmiObject Win32_ComputerSystem).DomainRole
if ($domainRole -ge 4) {
    Write-Host "$hostname is already a Domain Controller. Skipping promotion."
    return
}

Write-Host "Promoting $hostname to additional Domain Controller in domain: $DomainName..."

Install-ADDSDomainController `
    -DomainName $DomainName `
    -Credential (New-Object System.Management.Automation.PSCredential($AdminUser, $DomainAdminPassword)) `
    -SafeModeAdministratorPassword $SafeModePassword `
    -InstallDns:$true `
    -Force

Write-Host "$hostname has been promoted to Domain Controller successfully."
