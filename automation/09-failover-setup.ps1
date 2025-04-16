# 09-failover-setup.ps1

Import-Module DhcpServer
. "$PSScriptRoot\..\config.ps1"

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
