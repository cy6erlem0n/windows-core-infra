# 06-gpo-setup.ps1

. "$PSScriptRoot\00-config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()
if ($hostname -ne $PrimaryHostname.ToUpper()) {
    Write-Error "This script must be run on $PrimaryHostname"
    exit 1
}

$OUName = "SupportOU"
$OUPath = "OU=$OUName,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"
$GPOName = "DisableTaskManager"

# Проверка и создание GPO
if (-not (Get-GPO -Name $GPOName -ErrorAction SilentlyContinue)) {
    Write-Host "Creating GPO: $GPOName"
    New-GPO -Name $GPOName | Out-Null
    Set-GPRegistryValue -Name $GPOName `
        -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
        -ValueName "DisableTaskMgr" -Type DWord -Value 1
} else {
    Write-Host "GPO $GPOName already exists. Skipping creation."
}

# Проверка и создание OU
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$OUName'" -ErrorAction SilentlyContinue)) {
    Write-Host "Creating OU: $OUName"
    New-ADOrganizationalUnit -Name $OUName | Out-Null
} else {
    Write-Host "OU $OUName already exists. Skipping creation."
}

# Перемещение пользователя, если он еще не там
$user = Get-ADUser ipetrov
if ($user.DistinguishedName -notlike "*$OUPath*") {
    Write-Host "Moving user ipetrov to $OUPath"
    Move-ADObject -Identity $user.DistinguishedName -TargetPath $OUPath
} else {
    Write-Host "User ipetrov already in $OUPath. Skipping move."
}

# Проверка и привязка GPO
$gpoLinked = Get-GPInheritance -Target $OUPath | Select-Object -ExpandProperty GpoLinks | Where-Object { $_.DisplayName -eq $GPOName }

if (-not $gpoLinked) {
    Write-Host "Linking GPO $GPOName to $OUPath"
    New-GPLink -Name $GPOName -Target $OUPath | Out-Null
} else {
    Write-Host "GPO $GPOName already linked to $OUPath. Skipping."
}

Write-Host "GPO and OU configuration complete."
