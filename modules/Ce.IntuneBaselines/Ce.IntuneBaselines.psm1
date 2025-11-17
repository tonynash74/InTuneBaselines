$moduleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot   = Split-Path -Parent $moduleRoot
$scriptsRoot = Join-Path $repoRoot "scripts"

function Import-CeBaseline {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("L1", "L2")]
        [string]$Level,

        [string]$BaselineRoot = (Join-Path $repoRoot "baselines"),

        [string]$VersionTag = "2025-04",

        [ValidateSet("Android", "iOS", "Windows 11", "macOS")]
        [string[]]$Platforms,

        [ValidateSet("BYOD", "CORP")]
        [string[]]$Scopes,

        [ValidateSet("Compliance", "Config")]
        [string[]]$Types
    )

    $scriptPath = Join-Path $scriptsRoot "Import-IntuneBaselines.ps1"

    if (-not (Test-Path $scriptPath)) {
        throw "Import-IntuneBaselines.ps1 not found at $scriptPath"
    }

    $params = @{
        Level        = $Level
        BaselineRoot = $BaselineRoot
        VersionTag   = $VersionTag
    }

    if ($PSBoundParameters.ContainsKey('Platforms')) {
        $params.Platforms = $Platforms
    }
    if ($PSBoundParameters.ContainsKey('Scopes')) {
        $params.Scopes = $Scopes
    }
    if ($PSBoundParameters.ContainsKey('Types')) {
        $params.Types = $Types
    }

    & $scriptPath @params
}


function Invoke-CeBaselineDeployment {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$TenantConfigPath = (Join-Path $repoRoot "tenants/tenants.json"),

        [ValidateSet("L1", "L2", "Both")]
        [string]$DefaultBaselineLevel = "Both",

        [string]$DefaultVersionTag = "2025-04",

        [switch]$WhatIf
    )

    $scriptPath = Join-Path $scriptsRoot "Invoke-CeBaselineDeployment.ps1"

    if (-not (Test-Path $scriptPath)) {
        throw "Invoke-CeBaselineDeployment.ps1 not found at $scriptPath"
    }

    $params = @{
        TenantConfigPath      = $TenantConfigPath
        DefaultBaselineLevel  = $DefaultBaselineLevel
        DefaultVersionTag     = $DefaultVersionTag
    }

    if ($WhatIf) {
        $params.WhatIf = $true
    }

    & $scriptPath @params
}

function Get-CeSettingsCatalog {
    [CmdletBinding()]
    param(
        [ValidateSet("all", "android", "iOS", "macOS", "windows10", "windows10X")]
        [string]$Platform = "all",

        [string]$Search,

        [switch]$IncludeSettings,

        [string]$ExportJsonPath,

        [string]$ExportMarkdownPath
    )

    $scriptPath = Join-Path $scriptsRoot "Get-CeIntuneSettingsCatalog.ps1"

    if (-not (Test-Path $scriptPath)) {
        throw "Get-CeIntuneSettingsCatalog.ps1 not found at $scriptPath"
    }

    $params = @{
        Platform = $Platform
        Search   = $Search
    }

    if ($IncludeSettings)   { $params.IncludeSettings   = $true }
    if ($ExportJsonPath)    { $params.ExportJsonPath    = $ExportJsonPath }
    if ($ExportMarkdownPath){ $params.ExportMarkdownPath= $ExportMarkdownPath }

    & $scriptPath @params
}

function Compare-CeBaselines {
    [CmdletBinding()]
    param(
        [string]$BaselinesRoot = (Join-Path $repoRoot "baselines"),

        [ValidateSet("All", "L1", "L2")]
        [string]$Level = "All",

        [switch]$IncludeCompliance,

        [switch]$IncludeConfigurations,

        [string]$ReportPath
    )

    $scriptPath = Join-Path $scriptsRoot "Compare-CeBaselines.ps1"

    if (-not (Test-Path $scriptPath)) {
        throw "Compare-CeBaselines.ps1 not found at $scriptPath"
    }

    $params = @{
        BaselinesRoot = $BaselinesRoot
        Level         = $Level
    }

    if ($IncludeCompliance)      { $params.IncludeCompliance      = $true }
    if ($IncludeConfigurations)  { $params.IncludeConfigurations  = $true }
    if ($ReportPath)             { $params.ReportPath             = $ReportPath }

    & $scriptPath @params
}

function Get-CeTenantReadiness {
    [CmdletBinding()]
    param(
        [string]$VersionTag = "2025-04",

        [switch]$AsJson
    )

    $scriptPath = Join-Path $scriptsRoot "Get-CeTenantReadiness.ps1"

    if (-not (Test-Path $scriptPath)) {
        throw "Get-CeTenantReadiness.ps1 not found at $scriptPath"
    }

    $params = @{
        VersionTag = $VersionTag
    }

    if ($AsJson) {
        $params.AsJson = $true
    }

    & $scriptPath @params
}

Export-ModuleMember -Function `
    Import-CeBaseline, `
    Invoke-CeBaselineDeployment, `
    Get-CeSettingsCatalog, `
    Compare-CeBaselines, `
    Get-CeTenantReadiness
