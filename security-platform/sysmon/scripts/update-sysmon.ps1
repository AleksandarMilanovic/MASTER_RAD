$Base = Split-Path -Parent $MyInvocation.MyCommand.Path

$PackageDir = Join-Path $Base "..\packages"
$ConfigDir = Join-Path $Base "..\config"

& "$PackageDir\Sysmon64.exe" -c "$ConfigDir\sysmonconfig.xml"