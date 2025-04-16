# 05-dns-dhcp-primary.ps1

. "$PSScriptRoot\..\config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()
if ($hostname -ne $PrimaryHostname.ToUpper()) {
    Write-Error "This script must be run on $PrimaryHostname"
    exit 1
}

# DNS зона
Write-Host "Creating DNS zone $DomainName"
Add-DnsServerPrimaryZone -Name $DomainName -ReplicationScope "Domain" -PassThru

# DHCP Scope
Write-Host "Creating DHCP Scope"
Add-DhcpServerv4Scope -Name "MainScope" `
    -StartRange $DhcpScopeStart -EndRange $DhcpScopeEnd `
    -SubnetMask $DhcpMask `
    -State Active

# DHCP Options
Set-DhcpServerv4OptionValue -ScopeId $DhcpSubnet `
    -DnsDomain $DomainName `
    -DnsServer $DnsServer `
    -Router $Gateway

Write-Host "Authorizing DHCP Server"
Add-DhcpServerInDC -DnsName "$PrimaryHostname.$DomainName" -IpAddress $PrimaryIP

Write-Host "DNS and DHCP configured successfully on $PrimaryHostname"
