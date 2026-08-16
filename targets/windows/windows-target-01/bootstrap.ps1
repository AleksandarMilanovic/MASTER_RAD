#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

$TargetRoot = Split-Path `
    -Parent $MyInvocation.MyCommand.Path

$ProjectRoot = Resolve-Path `
    "$TargetRoot\..\..\.."


$config = Import-PowerShellDataFile `
    "$TargetRoot\config\hcr-windows-config.psd1"


Write-Host ""
Write-Host "=============================================="
Write-Host "       HYBRID CYBER RANGE"
Write-Host "       Windows Target Bootstrap"
Write-Host "=============================================="


#
# 1. Connectivity
#

Write-Host ""
Write-Host "[1/6] Testing HCR server connectivity..."


$requiredPorts = @(
    1514,
    1515
)


foreach ($port in $requiredPorts) {

    $result = Test-NetConnection `
        $config.HCRServer `
        -Port $port `
        -WarningAction SilentlyContinue


    if (-not $result.TcpTestSucceeded) {

        throw `
            "Unable to reach $($config.HCRServer):$port"

    }

    Write-Host "[OK] TCP/$port"

}


#
# 2. Hostname
#

Write-Host ""
Write-Host "[2/6] Configuring hostname..."


if ($env:COMPUTERNAME -ne $config.ComputerName) {

    Write-Host `
        "[INFO] Hostname will be changed to $($config.ComputerName)"

    Rename-Computer `
        -NewName $config.ComputerName `
        -Force

    $restartRequired = $true

}
else {

    Write-Host "[OK] Hostname already configured"

}


#
# 3. Windows auditing
#

Write-Host ""
Write-Host "[3/6] Configuring Windows auditing..."

& "$TargetRoot\scripts\Configure-Auditing.ps1"


#
# 4. Sysmon
#

Write-Host ""
Write-Host "[4/6] Configuring Sysmon..."


$sysmonExe = Join-Path `
    $ProjectRoot `
    "security-platform\sysmon\packages\Sysmon64.exe"


$sysmonConfig = Join-Path `
    $ProjectRoot `
    "security-platform\sysmon\config\sysmonconfig.xml"


& "$TargetRoot\scripts\Install-Sysmon.ps1" `
    -SysmonExecutable $sysmonExe `
    -ConfigFile $sysmonConfig


#
# 5. Wazuh Agent
#

Write-Host ""
Write-Host "[5/6] Configuring Wazuh Agent..."


$wazuhInstaller = Join-Path `
    $TargetRoot `
    "packages\$($config.Wazuh.Installer)"


& "$TargetRoot\scripts\Install-WazuhAgent.ps1" `
    -Manager $config.Wazuh.Manager `
    -AgentName $config.Wazuh.AgentName `
    -Installer $wazuhInstaller


#
# 6. CALDERA connectivity
#

Write-Host ""
Write-Host "[6/6] Checking CALDERA connectivity..."


$calderaTest = Test-NetConnection `
    $config.HCRServer `
    -Port 8888 `
    -WarningAction SilentlyContinue


if ($calderaTest.TcpTestSucceeded) {

    Write-Host "[OK] CALDERA TCP/8888 reachable"

}
else {

    Write-Host "[WARN] CALDERA TCP/8888 unavailable"
}


#
# Validation
#

Write-Host ""
Write-Host "Running final validation..."


& "$TargetRoot\scripts\Validate-HCRWindows.ps1" `
    -HCRServer $config.HCRServer


Write-Host ""
Write-Host "=============================================="
Write-Host " Windows Target Bootstrap Completed"
Write-Host "=============================================="


if ($restartRequired) {

    Write-Host ""
    Write-Host "[INFO] Computer rename requires restart."
    Write-Host "[INFO] Restart Windows before running experiments."

}
