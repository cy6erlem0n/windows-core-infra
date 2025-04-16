# 01-configure-network.ps1

. "$PSScriptRoot\..\config.ps1"

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

Write-Host "Configuring IP settings on $ifAlias..."
Get-NetIPAddress -InterfaceAlias $ifAlias | Remove-NetIPAddress -Confirm:$false
Get-NetIPConfiguration -InterfaceAlias $ifAlias | Remove-NetRoute -Confirm:$false

New-NetIPAddress -InterfaceAlias $ifAlias -IPAddress $ip -PrefixLength 24 -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceAlias $ifAlias -ServerAddresses $dns

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
