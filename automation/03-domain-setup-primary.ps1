# 03-domain-setup-primary.ps1

. "$PSScriptRoot\00-config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()

if ($hostname -ne $PrimaryHostname.ToUpper()) {
    Write-Error "This script must be run on $PrimaryHostname"
    exit 1
}

try {
    $domain = Get-ADDomain -ErrorAction Stop
    Write-Host "$hostname уже является контроллером домена ($($domain.Name)). Пропускаем установку."
    return
} catch {
    Write-Host "$hostname не является контроллером домена. Продолжаем настройку..."
}

Write-Host "Promoting $hostname to Domain Controller and creating new forest: $DomainName"

Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainNetbiosName `
    -SafeModeAdministratorPassword $SafeModePassword `
    -InstallDns:$true `
    -Force
