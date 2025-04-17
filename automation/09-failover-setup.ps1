# 09-failover-setup.ps1
. "$PSScriptRoot\00-config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()
if ($hostname -ne $PrimaryHostname.ToUpper()) {
    Write-Error "This script must be run on $PrimaryHostname"
    exit 1
}

Import-Module DhcpServer

Write-Host "[DHCP FAILOVER] Checking if failover already exists..."
$failover = Get-DhcpServerv4Failover -Name "DHCPFailover" -ErrorAction SilentlyContinue

if ($failover) {
    Write-Host "[DHCP FAILOVER] Failover already configured. Skipping."
} else {
    Write-Host "[DHCP FAILOVER] Configuring DHCP Failover..."

    try {
        Add-DhcpServerv4Failover `
            -Name "DHCPFailover" `
            -ScopeId $DhcpSubnet `
            -PartnerServer $SecondaryHostname `
            -SharedSecret "MySuperSecret123!" `
            -AutoStateTransition $true `
            -StateSwitchInterval 00:10:00 `
            -MaxClientLeadTime 01:00:00 `
            -LoadBalancePercent 50 `
            -Force

        Write-Host "[DHCP FAILOVER] DHCP Failover configured successfully."
    } catch {
        Write-Warning "[DHCP FAILOVER] Error configuring DHCP Failover: $_"
    }
}
