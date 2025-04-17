# 05-dns-dhcp-secondary.ps1

. "$PSScriptRoot\00-config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()
if ($hostname -ne $SecondaryHostname.ToUpper()) {
    Write-Error "This script must be run on $SecondaryHostname"
    exit 1
}

Write-Host "Checking DHCP authorization for $SecondaryHostname..."


$authorized = Get-DhcpServerInDC -ErrorAction SilentlyContinue | Where-Object { $_.DnsName -eq "$SecondaryHostname.$DomainName" }

if ($authorized) {
    Write-Host "DHCP Server on $SecondaryHostname is already authorized. Skipping."
} else {
    try {
        Write-Host "Authorizing DHCP Server on $SecondaryHostname..."
        Add-DhcpServerInDC -DnsName "$SecondaryHostname.$DomainName" -IPAddress $SecondaryIP
        Write-Host "Secondary DHCP Server authorized successfully."
    } catch {
        Write-Error "Failed to authorize DHCP Server on ${SecondaryHostname}: $_"
    }
}

Write-Host "Note: DNS zone should be replicated automatically via Active Directory replication."
