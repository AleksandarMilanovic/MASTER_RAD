$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== Windows Audit Configuration ==="


$subcategories = @(
    "Process Creation",
    "Logon",
    "Logoff",
    "Account Lockout",
    "User Account Management",
    "Security Group Management"
)


foreach ($subcategory in $subcategories) {

    Write-Host "[INFO] Configuring: $subcategory"

    auditpol.exe `
        /set `
        /subcategory:"$subcategory" `
        /success:enable `
        /failure:enable `
        | Out-Null
}


#
# Include command line in Event ID 4688.
#

$registryPath = `
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit"

if (-not (Test-Path $registryPath)) {
    New-Item `
        -Path $registryPath `
        -Force |
        Out-Null
}


New-ItemProperty `
    -Path $registryPath `
    -Name "ProcessCreationIncludeCmdLine_Enabled" `
    -PropertyType DWord `
    -Value 1 `
    -Force |
    Out-Null


Write-Host "[OK] Windows auditing configured."
