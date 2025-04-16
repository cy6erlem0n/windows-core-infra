# Set-FsrmQuota.ps1

$quotaManager = New-Object -ComObject "Fsrm.FsrmQuotaManager"

$quota = $quotaManager.CreateQuota("C:\SharedFolder")

$quota.QuotaLimit = 209715200

$quota.Commit()

Write-Host "The quota has been successfully created!"