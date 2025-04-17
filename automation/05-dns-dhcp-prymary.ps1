# 05-dns-dhcp-prymary.ps1

. "$PSScriptRoot\00-config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()
if ($hostname -ne $PrimaryHostname.ToUpper()) {
    Write-Error "This script must be run on $PrimaryHostname"
    exit 1
}

Write-Host "Creating DHCP Scope"

if (-not (Get-DhcpServerv4Scope -ScopeId $DhcpSubnet -ErrorAction SilentlyContinue)) {
    Add-DhcpServerv4Scope -Name "MainScope" `
        -StartRange $DhcpScopeStart -EndRange $DhcpScopeEnd `
        -SubnetMask $DhcpMask -State Active
    Write-Host "DHCP Scope created."
} else {
    Write-Host "DHCP Scope already exists. Skipping creation."
}


$currentOptions = Get-DhcpServerv4OptionValue -ScopeId $DhcpSubnet
if ($currentOptions.DnsServer.ServerAddresses -ne $DnsServer) {
    Set-DhcpServerv4OptionValue -ScopeId $DhcpSubnet `
        -DnsDomain $DomainName `
        -DnsServer $DnsServer `
        -Router $Gateway
    Write-Host "DHCP options updated."
} else {
    Write-Host "DHCP options already set. Skipping."
}

Write-Host "Authorizing DHCP Server..."
if (-not (Get-DhcpServerInDC -ComputerName $env:COMPUTERNAME -ErrorAction SilentlyContinue)) {
    Add-DhcpServerInDC -DnsName "$PrimaryHostname.$DomainName" -IpAddress $PrimaryIP
    Write-Host "DHCP Server authorized."
} else {
    Write-Host "DHCP Server already authorized. Skipping."
}

Write-Host "DNS and DHCP configured successfully on $PrimaryHostname"
