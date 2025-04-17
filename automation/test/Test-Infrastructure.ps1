# Test-Infrastructure.ps1

$errors = 0

# 1. DNS resolution
try {
    Resolve-DnsName main.local -ErrorAction Stop | Out-Null
    Write-Host " DNS resolution successful."
} catch {
    Write-Warning " DNS resolution failed."
    $errors++
}

# 2. Shared folder access
if (Test-Path "\\main.local\share") {
    Write-Host " Shared folder accessible."
} else {
    Write-Warning " Shared folder not accessible."
    $errors++
}

# 3. Domain availability
try {
    Get-ADDomain | Out-Null
    Write-Host " Domain is reachable."
} catch {
    Write-Warning " Domain is not reachable."
    $errors++
}

# 4. DHCP check
$ip = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null }).IPv4Address.IPAddress
if ($ip) {
    Write-Host " IP address assigned via DHCP: $ip"
} else {
    Write-Warning " IP address not assigned via DHCP."
    $errors++
}

# 5. IIS website check
try {
    $resp = Invoke-WebRequest -Uri "http://10.0.0.1" -UseBasicParsing -TimeoutSec 5
    if ($resp.StatusCode -eq 200) {
        Write-Host " IIS site is reachable (HTTP 200)."
    } else {
        throw "Status code: $($resp.StatusCode)"
    }
} catch {
    Write-Warning " IIS site not reachable: $_"
    $errors++
}

# 6. DFS folder access
if (Test-Path "\\main.local\share\Docs") {
    Write-Host " DFS folder reachable."
} else {
    Write-Warning " DFS folder not reachable."
    $errors++
}

# 7. Additional Domain Controller check
try {
    $dc = Get-ADDomainController -Filter { Name -eq "SRV-CORE2" }
    Write-Host " Secondary Domain Controller is available: $($dc.Name)"
} catch {
    Write-Warning " Secondary Domain Controller not found."
    $errors++
}

# 8. Robocopy Replication Check
$replicatedFile = "\\SRV-CORE2\ReplicationDataShare\replica-test.txt"

if (Test-Path $replicatedFile) {
    Write-Host " Replication working — file exists on secondary."
} else {
    Write-Warning " Replication may not be working — test file not found on secondary."
    $errors++
}

# === Summary ===
if ($errors -eq 0) {
    Write-Host "`n All checks passed. Infrastructure is healthy."
} else {
    Write-Warning "`n Number of issues detected: $errors"
}
