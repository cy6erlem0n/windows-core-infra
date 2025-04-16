# 04-ad-users-groups.ps1

. "$PSScriptRoot\..\config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()
if ($hostname -ne $PrimaryHostname.ToUpper()) {
    Write-Error "This script must be run on $PrimaryHostname"
    exit 1
}

# Create AD users
New-ADUser -Name "Ivan Petrov" -GivenName "Ivan" -Surname "Petrov" -SamAccountName "ipetrov" `
    -UserPrincipalName "ipetrov@$DomainName" -AccountPassword (ConvertTo-SecureString "SmartPass123!" -AsPlainText -Force) -Enabled $true

New-ADUser -Name "Anna Ivanova" -GivenName "Anna" -Surname "Ivanova" -SamAccountName "aivanova" `
    -UserPrincipalName "aivanova@$DomainName" -AccountPassword (ConvertTo-SecureString "AlsoSmartPass123!" -AsPlainText -Force) -Enabled $true

# Create AD groups
New-ADGroup -Name "Support" -GroupScope Global -GroupCategory Security
New-ADGroup -Name "DevOps" -GroupScope Global -GroupCategory Security

# Add users to groups
Add-ADGroupMember -Identity "Support" -Members "ipetrov"
Add-ADGroupMember -Identity "DevOps" -Members "aivanova"

Write-Host "Users and groups created successfully."
