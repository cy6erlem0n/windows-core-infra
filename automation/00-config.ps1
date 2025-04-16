# config.ps1

# ==== NETWORK SETTINGS ====
$PrimaryHostname    = "SRV-CORE1"
$PrimaryIP          = "10.0.0.1"
$SecondaryHostname  = "SRV-CORE2"
$SecondaryIP        = "10.0.0.2"
$SubnetMask         = "255.255.255.0"
$Gateway            = "10.0.0.254"
$DnsServer          = $PrimaryIP

# ==== DOMAIN SETTINGS ====
$DomainName            = "main.local"
$DomainNetbiosName     = "MAIN"
$SafeModePassword      = ConvertTo-SecureString "MAINpass123!" -AsPlainText -Force
$DomainAdminPassword   = ConvertTo-SecureString "Smart123" -AsPlainText -Force  
$LocalAdminPassword    = ConvertTo-SecureString "Smart123" -AsPlainText -Force

# ==== DHCP SETTINGS ====
$DhcpScopeStart     = "10.0.0.100"
$DhcpScopeEnd       = "10.0.0.200"
$DhcpSubnet         = "10.0.0.0"
$DhcpMask           = "255.255.255.0"
$DhcpLeaseDuration  = ([TimeSpan]::FromDays(7))

# ==== DFS / SHARE SETTINGS ====
$NamespaceRoot      = "\\main.local\share"
$NamespaceName      = "share"
$SharedFolderPath   = "C:\SharedFolder"
$QuotaLimitBytes    = 209715200 #200MB

# ==== IIS SETTINGS ====
$IISSiteName        = "TestSite"
$IISSitePort        = 80
$IISSitePath        = "C:\inetpub\wwwroot"

# ==== GENERAL ====
$AdminUser          = "MAIN\Administrator"
