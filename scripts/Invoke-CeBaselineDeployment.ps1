[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$TenantConfigPath = "./tenants/tenants.json",

    [ValidateSet("L1", "L2", "Both")]
    [string]$DefaultBaselineLevel = "Both",

    [string]$DefaultVersionTag = "2025-04",

    [switch]$WhatIf
)

<#
.SYNOPSIS
    Deploy CE L1/L2 baselines to multiple tenants.

.DESCRIPTION
    Reads tenants from a JSON file and, for each, connects to Microsoft Graph using
    app-only auth, then calls Import-IntuneBaselines.ps1 with the requested level.

    Each tenant entry should include:
      - TenantId
      - DisplayName
      - BaselineLevel (L1, L2, Both) – optional, falls back to DefaultBaselineLevel
      - VersionTag – optional, falls back to DefaultVersionTag
      - ClientId
      - CertificateThumbprint

    Requires:
      - Microsoft Graph PowerShell SDK
      - DeviceManagementConfiguration.ReadWrite.All app permission consented
#>

if (-not (Test-Path $TenantConfigPath)) {
    throw "Tenant config file not found: $TenantConfigPath"
}

$tenants = Get-Content -Raw -Path $TenantConfigPath | ConvertFrom-Json

$importScript = Join-Path $PSScriptRoot "Import-IntuneBaselines.ps1"
if (-not (Test-Path $importScript)) {
    throw "Import-IntuneBaselines.ps1 not found at $importScript"
}

foreach ($tenant in $tenants) {
    $tenantId = $tenant.TenantId
    $displayName = $tenant.DisplayName
    $baselineLevel = if ($tenant.BaselineLevel) { $tenant.BaselineLevel } else { $DefaultBaselineLevel }
    $versionTag = if ($tenant.VersionTag) { $tenant.VersionTag } else { $DefaultVersionTag }

    if (-not $tenantId -or -not $tenant.ClientId -or -not $tenant.CertificateThumbprint) {
        Write-Warning "Skipping tenant '$displayName' – missing TenantId/ClientId/CertificateThumbprint."
        continue
    }

    $target = "Tenant $displayName ($tenantId) with CE $baselineLevel baselines (version $versionTag)"

    if ($PSCmdlet.ShouldProcess($target, "Deploy CE baselines")) {

        Write-Host "Connecting to tenant $displayName ($tenantId)..." -ForegroundColor Cyan

        Disconnect-MgGraph -ErrorAction SilentlyContinue

        Connect-MgGraph `
            -TenantId $tenantId `
            -ClientId $tenant.ClientId `
            -CertificateThumbprint $tenant.CertificateThumbprint `
            -NoWelcome `
            -ErrorAction Stop

        Write-Host "Connected to $displayName. Deploying baselines..." -ForegroundColor Green

        if ($baselineLevel -eq "L1" -or $baselineLevel -eq "Both") {
            if ($WhatIf) {
                Write-Host "[WhatIf] Would deploy CE L1 baselines to $displayName." -ForegroundColor Yellow
            }
            else {
                & $importScript -Level "L1" -VersionTag $versionTag
            }
        }

        if ($baselineLevel -eq "L2" -or $baselineLevel -eq "Both") {
            if ($WhatIf) {
                Write-Host "[WhatIf] Would deploy CE L2 baselines to $displayName." -ForegroundColor Yellow
            }
            else {
                & $importScript -Level "L2" -VersionTag $versionTag
            }
        }
    }
}

Write-Host "Baseline deployment run complete." -ForegroundColor Green
