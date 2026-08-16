param(
    [Parameter(Mandatory)]
    [string]$SysmonExecutable,

    [Parameter(Mandatory)]
    [string]$ConfigFile
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== Sysmon Configuration ==="


if (-not (Test-Path $SysmonExecutable)) {
    throw "Sysmon executable not found: $SysmonExecutable"
}


if (-not (Test-Path $ConfigFile)) {
    throw "Sysmon configuration not found: $ConfigFile"
}


$service = Get-Service `
    -Name Sysmon64 `
    -ErrorAction SilentlyContinue


if (-not $service) {

    Write-Host "[INFO] Installing Sysmon..."

    & $SysmonExecutable `
        -accepteula `
        -i $ConfigFile

    if ($LASTEXITCODE -ne 0) {
        throw "Sysmon installation failed."
    }

}
else {

    Write-Host "[INFO] Sysmon already installed."
    Write-Host "[INFO] Updating configuration..."

    & $SysmonExecutable `
        -c $ConfigFile

}


$service = Get-Service `
    -Name Sysmon64 `
    -ErrorAction SilentlyContinue


if ($service -and $service.Status -ne "Running") {
    Start-Service Sysmon64
}


Write-Host "[OK] Sysmon configured."
