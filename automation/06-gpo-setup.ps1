# 06-gpo-setup.ps1

. "$PSScriptRoot\..\config.ps1"

$hostname = $env:COMPUTERNAME.ToUpper()
if ($hostname -ne $PrimaryHostname.ToUpper()) {
    Write-Error "This script must be run on $PrimaryHostname"
    exit 1
}

# Compose OU path dynamically
$OUName = "SupportOU"
$OUPath = "OU=$OUName,DC=$($DomainName.Split('.')[0]),DC=$($DomainName.Split('.')[1])"

# Create GPO to disable Task Manager
New-GPO -Name "DisableTaskManager"
Set-GPRegistryValue -Name "DisableTaskManager" `
  -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
  -ValueName "DisableTaskMgr" -Type DWord -Value 1

# Create OU and move user
New-ADOrganizationalUnit -Name $OUName
Get-ADUser ipetrov | Move-ADObject -TargetPath $OUPath

# Link GPO to OU
New-GPLink -Name "DisableTaskManager" -Target $OUPath

Write-Host "GPO and OU configuration complete."
