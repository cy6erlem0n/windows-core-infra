# 02-install-roles.ps1

. "$PSScriptRoot\..\config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()

if ($hostname -eq $PrimaryHostname.ToUpper()) {
    $roles = @(
        "AD-Domain-Services",
        "DNS",
        "DHCP",
        "FS-DFS-Namespace",
        "FS-Resource-Manager",
        "Web-Server"
    )
    $includeMgmtTools = $true
} elseif ($hostname -eq $SecondaryHostname.ToUpper()) {
    $roles = @(
        "AD-Domain-Services",
        "DHCP"
    )
    $includeMgmtTools = $true
} else {
    Write-Error "Unknown hostname: $hostname. Expected $PrimaryHostname or $SecondaryHostname."
    exit 1
}

foreach ($role in $roles) {
    Write-Host "Installing role: $role"
    Install-WindowsFeature -Name $role -IncludeManagementTools:$includeMgmtTools | Out-Null
}

Write-Host "Role installation complete."
