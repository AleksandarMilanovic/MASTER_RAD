$Base = Split-Path -Parent $MyInvocation.MyCommand.Path

$PackageDir = Join-Path $Base "..\packages"

& "$PackageDir\Sysmon64.exe" -u force