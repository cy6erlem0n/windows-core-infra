# 02-install-roles.ps1

. "$PSScriptRoot\00-config.ps1"

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
} elseif ($hostname -eq $SecondaryHostname.ToUpper()) {
    $roles = @(
        "AD-Domain-Services",
        "DHCP"
    )
} else {
    Write-Error "Unknown hostname: $hostname. Expected $PrimaryHostname or $SecondaryHostname."
    exit 1
}

foreach ($role in $roles) {
    $feature = Get-WindowsFeature -Name $role
    if ($feature.Installed) {
        Write-Host "[$role] already installed. Skipping."
    } else {
        Write-Host "Installing [$role]..."
        Install-WindowsFeature -Name $role -IncludeManagementTools | Out-Null
        Write-Host "[$role] installed successfully."
    }
}

Write-Host "Role installation complete on $hostname."
