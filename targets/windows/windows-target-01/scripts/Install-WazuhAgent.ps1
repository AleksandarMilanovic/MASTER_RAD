param(
    [Parameter(Mandatory)]
    [string]$Manager,

    [Parameter(Mandatory)]
    [string]$AgentName,

    [Parameter(Mandatory)]
    [string]$Installer
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== Wazuh Agent Installation ==="

$service = Get-Service `
    -Name "WazuhSvc" `
    -ErrorAction SilentlyContinue

if ($service) {

    Write-Host "[INFO] Wazuh Agent already installed."

    if ($service.Status -ne "Running") {
        Start-Service WazuhSvc
    }

    Write-Host "[OK] Wazuh Agent service running."

    return
}


if (-not (Test-Path $Installer)) {
    throw "Wazuh installer not found: $Installer"
}


Write-Host "[INFO] Installing Wazuh Agent..."

$arguments = @(
    "/i"
    "`"$Installer`""
    "/qn"
    "WAZUH_MANAGER=$Manager"
    "WAZUH_AGENT_NAME=$AgentName"
)

$process = Start-Process `
    -FilePath "msiexec.exe" `
    -ArgumentList $arguments `
    -Wait `
    -PassThru


if ($process.ExitCode -notin @(0, 3010)) {
    throw "Wazuh installation failed: $($process.ExitCode)"
}


Write-Host "[INFO] Starting Wazuh service..."

Start-Service WazuhSvc


Set-Service `
    -Name WazuhSvc `
    -StartupType Automatic


Write-Host "[OK] Wazuh Agent installed."
Write-Host "[OK] Manager: $Manager"
Write-Host "[OK] Agent:   $AgentName"
