# 01-configure-network.ps1

. "$PSScriptRoot\00-config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()

if ($hostname -eq $PrimaryHostname.ToUpper()) {
    $ip = $PrimaryIP
    $dns = $DnsServerPrimary
    $peer = $SecondaryIP
} elseif ($hostname -eq $SecondaryHostname.ToUpper()) {
    $ip = $SecondaryIP
    $dns = $DnsServerSecondary
    $peer = $PrimaryIP
} else {
    Write-Error "Unknown hostname: $hostname. Expected $PrimaryHostname or $SecondaryHostname."
    exit 1
}

$interface = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
if (-not $interface) {
    Write-Error "No active network interface found."
    exit 1
}

$ifAlias = $interface.Name
Write-Host "Using network interface: $ifAlias"

$currentIP = Get-NetIPAddress -InterfaceAlias $ifAlias -ErrorAction SilentlyContinue
if ($currentIP) {
    Write-Host "Removing existing IP addresses..."
    $currentIP | Remove-NetIPAddress -Confirm:$false
}

$currentRoutes = Get-NetIPConfiguration -InterfaceAlias $ifAlias | Select-Object -ExpandProperty IPv4DefaultGateway
if ($currentRoutes) {
    Write-Host "Removing existing default routes..."
    Get-NetIPConfiguration -InterfaceAlias $ifAlias | Remove-NetRoute -Confirm:$false
}

if (-not (Test-Connection -ComputerName $ip -Count 1 -Quiet)) {
    Write-Host "Assigning static IP: $ip"
    New-NetIPAddress -InterfaceAlias $ifAlias -IPAddress $ip -PrefixLength 24 -DefaultGateway $Gateway
} else {
    Write-Warning "IP $ip already responds to ping. Возможно, он уже используется."
}

Write-Host "Setting DNS server: $dns"
Set-DnsClientServerAddress -InterfaceAlias $ifAlias -ServerAddresses $dns

Write-Host "Disabling firewall..."
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

Enable-PSRemoting -Force

Write-Host "Testing WinRM connection to peer: $peer"
try {
    Test-WSMan $peer -ErrorAction Stop | Out-Null
    Write-Host "WinRM connection to $peer successful."
} catch {
    Write-Warning "WinRM connection to $peer failed: $_"
}

Write-Host "Network configuration complete."
