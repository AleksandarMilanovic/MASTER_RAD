param(
    [Parameter(Mandatory)]
    [string]$HCRServer
)

$ErrorActionPreference = "Continue"

$failures = 0


Write-Host ""
Write-Host "========================================"
Write-Host " HCR Windows Target Validation"
Write-Host "========================================"


#
# Hostname
#

Write-Host ""
Write-Host "=== Host ==="

Write-Host "[INFO] Hostname: $env:COMPUTERNAME"


#
# Wazuh
#

Write-Host ""
Write-Host "=== Wazuh Agent ==="

$wazuh = Get-Service `
    -Name WazuhSvc `
    -ErrorAction SilentlyContinue

if ($wazuh -and $wazuh.Status -eq "Running") {
    Write-Host "[OK] Wazuh Agent running"
}
else {
    Write-Host "[FAIL] Wazuh Agent unavailable"
    $failures++
}


#
# Sysmon
#

Write-Host ""
Write-Host "=== Sysmon ==="

$sysmon = Get-Service `
    -Name Sysmon64 `
    -ErrorAction SilentlyContinue

if ($sysmon -and $sysmon.Status -eq "Running") {
    Write-Host "[OK] Sysmon running"
}
else {
    Write-Host "[FAIL] Sysmon unavailable"
    $failures++
}


#
# Wazuh communication
#

Write-Host ""
Write-Host "=== HCR Connectivity ==="

$ports = @{
    "Wazuh Agent"      = 1514
    "Wazuh Enrollment" = 1515
    "CALDERA"          = 8888
}


foreach ($entry in $ports.GetEnumerator()) {

    $result = Test-NetConnection `
        $HCRServer `
        -Port $entry.Value `
        -WarningAction SilentlyContinue


    if ($result.TcpTestSucceeded) {

        Write-Host `
            "[OK] $($entry.Key) TCP/$($entry.Value)"

    }
    else {

        Write-Host `
            "[FAIL] $($entry.Key) TCP/$($entry.Value)"

        $failures++
    }
}


#
# Sysmon event channel
#

Write-Host ""
Write-Host "=== Event Logs ==="

$log = Get-WinEvent `
    -ListLog `
    "Microsoft-Windows-Sysmon/Operational" `
    -ErrorAction SilentlyContinue


if ($log -and $log.IsEnabled) {

    Write-Host "[OK] Sysmon Operational log enabled"

}
else {

    Write-Host "[FAIL] Sysmon Operational log unavailable"

    $failures++
}


#
# Result
#

Write-Host ""
Write-Host "========================================"

if ($failures -eq 0) {

    Write-Host " Windows target ready"
    Write-Host "========================================"

    exit 0

}

Write-Host " Validation failed: $failures issue(s)"
Write-Host "========================================"

exit 1
