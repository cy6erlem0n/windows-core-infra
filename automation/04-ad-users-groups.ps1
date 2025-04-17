# 04-ad-users-groups.ps1

. "$PSScriptRoot\00-config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()
if ($hostname -ne $PrimaryHostname.ToUpper()) {
    Write-Error "This script must be run on $PrimaryHostname"
    exit 1
}

$users = @(
    @{
        Name = "Ivan Petrov"
        GivenName = "Ivan"
        Surname = "Petrov"
        SamAccountName = "ipetrov"
        UPN = "ipetrov@$DomainName"
        Password = "SmartPass123!"
    },
    @{
        Name = "Anna Ivanova"
        GivenName = "Anna"
        Surname = "Ivanova"
        SamAccountName = "aivanova"
        UPN = "aivanova@$DomainName"
        Password = "AlsoSmartPass123!"
    }
)

foreach ($user in $users) {
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($user.SamAccountName)'" -ErrorAction SilentlyContinue)) {
        New-ADUser -Name $user.Name `
            -GivenName $user.GivenName -Surname $user.Surname `
            -SamAccountName $user.SamAccountName `
            -UserPrincipalName $user.UPN `
            -AccountPassword (ConvertTo-SecureString $user.Password -AsPlainText -Force) `
            -Enabled $true
        Write-Host "User $($user.SamAccountName) created."
    } else {
        Write-Host "User $($user.SamAccountName) already exists. Skipping."
    }
}

$groups = @("Support", "DevOps")

foreach ($group in $groups) {
    if (-not (Get-ADGroup -Filter "Name -eq '$group'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $group -GroupScope Global -GroupCategory Security
        Write-Host "Group '$group' created."
    } else {
        Write-Host "Group '$group' already exists. Skipping."
    }
}

$groupMembership = @{
    "Support" = @("ipetrov")
    "DevOps"  = @("aivanova")
}

foreach ($group in $groupMembership.Keys) {
    foreach ($user in $groupMembership[$group]) {
        if (-not (Get-ADGroupMember -Identity $group | Where-Object { $_.SamAccountName -eq $user })) {
            Add-ADGroupMember -Identity $group -Members $user
            Write-Host "User $user added to $group."
        } else {
            Write-Host "User $user is already a member of $group. Skipping."
        }
    }
}

Write-Host "Users and groups created and verified successfully."
