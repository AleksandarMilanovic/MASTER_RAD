$ErrorActionPreference = "Stop"

$Base = Split-Path -Parent $MyInvocation.MyCommand.Path

$PackageDir = Join-Path $Base "..\packages"
$ConfigDir  = Join-Path $Base "..\config"

$Sysmon = Join-Path $PackageDir "Sysmon64.exe"
$Config = Join-Path $ConfigDir "sysmonconfig.xml"

Write-Host ""
Write-Host "Installing Sysmon..."
Write-Host ""

& $Sysmon -accepteula -i $Config

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "Sysmon service:"
Write-Host ""

Get-Service Sysmon64

Write-Host ""
Write-Host "Checking Event Log..."
Write-Host ""

Get-WinEvent -ListLog "Microsoft-Windows-Sysmon/Operational"

Write-Host ""
Write-Host "Done."