# 03-domain-setup-secondary.ps1

. "$PSScriptRoot\..\config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()

if ($hostname -ne $SecondaryHostname.ToUpper()) {
    Write-Error "This script must be run on $SecondaryHostname"
    exit 1
}

Write-Host "Joining domain $DomainName..."
Add-Computer -DomainName $DomainName -Credential $AdminUser -Force -Restart
