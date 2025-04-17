# 03-domain-setup-secondary.ps1

. "$PSScriptRoot\00-config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()

if ($hostname -ne $SecondaryHostname.ToUpper()) {
    Write-Error "This script must be run on $SecondaryHostname"
    exit 1
}

$secureCred = New-Object System.Management.Automation.PSCredential($AdminUser, $DomainAdminPassword)

$currentDomain = (Get-WmiObject Win32_ComputerSystem).PartOfDomain
if ($currentDomain) {
    Write-Host "$hostname уже в домене $DomainName. Пропускаем присоединение."
    return
}

Write-Host "Joining domain $DomainName..."

Add-Computer -DomainName $DomainName -Credential $secureCred -Force -Restart
