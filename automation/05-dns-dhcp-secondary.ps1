# 05-dns-dhcp-secondary.ps1

. "$PSScriptRoot\..\config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()
if ($hostname -ne $SecondaryHostname.ToUpper()) {
    Write-Error "This script must be run on $SecondaryHostname"
    exit 1
}

# Авторизация DHCP на резервном сервере
Write-Host "Authorizing DHCP Server on $SecondaryHostname"
Add-DhcpServerInDC -DnsName "$SecondaryHostname.$DomainName" -IPAddress $SecondaryIP

Write-Host "Secondary DHCP Server authorized successfully."

# DNS-зона должна автоматически реплицироваться через AD
