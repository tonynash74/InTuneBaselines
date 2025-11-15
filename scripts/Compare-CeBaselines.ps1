[CmdletBinding()]
param(
    [string]$BaselinesRoot = "./baselines",

    [ValidateSet("All", "L1", "L2")]
    [string]$Level = "All",

    [switch]$IncludeCompliance,

    [switch]$IncludeConfigurations,

    [string]$ReportPath
)

<#
.SYNOPSIS
    Compare CE baseline JSON files with live Intune policies to detect drift.

.DESCRIPTION
    Reads JSON baselines from ./baselines (L1/L2) and compares them with
    Intune deviceCompliancePolicies and deviceConfigurations using their
    displayName as the key.

    - If a baseline JSON has @odata.type ending with "CompliancePolicy", it
      is compared with /deviceManagement/deviceCompliancePolicies.
    - Otherwise, it is treated as a configuration profile and compared with
      /deviceManagement/deviceConfigurations.

    Only properties present in the baseline JSON are compared; server-
    managed fields (id, version, timestamps, etc) are ignored.

.REQUIREMENTS
    - Microsoft Graph PowerShell SDK
    - Connect-MgGraph -Scopes "DeviceManagementConfiguration.Read.All"
#>

if (-not $IncludeCompliance -and -not $IncludeConfigurations) {
    $IncludeCompliance = $true
    $IncludeConfigurations = $true
}

function Normalize-CeValue {
    param(
        [Parameter(Mandatory = $true)]
        $Value
    )

    if ($null -eq $Value) {
        return $null
    }

    if ($Value -is [string] -or
        $Value -is [int] -or
        $Value -is [bool]) {
        return $Value
    }

    # For arrays/objects, normalise via JSON
    return (ConvertTo-Json -InputObject $Value -Depth 20 -Compress)
}

$levelsToCheck = if ($Level -eq "All") { @("L1", "L2") } else { @($Level) }

$results = @()

foreach ($lvl in $levelsToCheck) {

    $levelPath = Join-Path $BaselinesRoot $lvl
    if (-not (Test-Path $levelPath)) {
        Write-Warning "Baselines path not found for level $lvl: $levelPath"
        continue
    }

    $jsonFiles = Get-ChildItem -Path $levelPath -Recurse -Filter "*.json" -ErrorAction SilentlyContinue

    foreach ($file in $jsonFiles) {
        $raw = Get-Content -Raw -Path $file.FullName
        $baseline = $raw | ConvertFrom-Json

        $odataType = $baseline.'@odata.type'
        $displayName = $baseline.displayName

        if (-not $odataType -or -not $displayName) {
            Write-Warning "Skipping $($file.FullName) – missing @odata.type or displayName."
            continue
        }

        $isCompliance = $odataType -like "*CompliancePolicy"

        if ($isCompliance -and -not $IncludeCompliance) { continue }
        if (-not $isCompliance -and -not $IncludeConfigurations) { continue }

        $escapedName = $displayName.Replace("'", "''")

        if ($isCompliance) {
            $livePolicies = Get-MgDeviceManagementDeviceCompliancePolicy `
                -Filter "displayName eq '$escapedName'" `
                -ErrorAction SilentlyContinue
        } else {
            $livePolicies = Get-MgDeviceManagementDeviceConfiguration `
                -Filter "displayName eq '$escapedName'" `
                -ErrorAction SilentlyContinue
        }

        if (-not $livePolicies) {
            $results += [pscustomobject]@{
                Level        = $lvl
                Type         = if ($isCompliance) { "Compliance" } else { "Config" }
                BaselineFile = $file.FullName
                DisplayName  = $displayName
                PolicyId     = $null
                Status       = "Missing"
                Differences  = @()
            }
            continue
        }

        # Use the first match (you generally shouldn't have duplicates)
        $live = $livePolicies | Select-Object -First 1

        $ignoreProps = @(
            '@odata.type',
            '@odata.context',
            'id',
            'version',
            'createdDateTime',
            'lastModifiedDateTime',
            'createdBy',
            'lastModifiedBy',
            'roleScopeTagIds',
            'supportsScopeTags'
        )

        $baselineProps = $baseline.PSObject.Properties |
            Where-Object { $_.Name -notin $ignoreProps }

        $diffs = @()

        foreach ($prop in $baselineProps) {
            $name = $prop.Name
            $baselineVal = $prop.Value
            $liveVal = $live.$name

            $normBaseline = Normalize-CeValue $baselineVal
            $normLive = Normalize-CeValue $liveVal

            if ($normBaseline -ne $normLive) {
                $diffs += [pscustomobject]@{
                    PropertyName  = $name
                    BaselineValue = $baselineVal
                    LiveValue     = $liveVal
                }
            }
        }

        $status = if ($diffs.Count -eq 0) { "Match" } else { "Drift" }

        $results += [pscustomobject]@{
            Level        = $lvl
            Type         = if ($isCompliance) { "Compliance" } else { "Config" }
            BaselineFile = $file.FullName
            DisplayName  = $displayName
            PolicyId     = $live.id
            Status       = $status
            Differences  = $diffs
        }
    }
}

# Default console output
$results |
    Select-Object Level, Type, DisplayName, Status, PolicyId, BaselineFile |
    Sort-Object Level, Type, DisplayName |
    Format-Table -AutoSize

# Optional report
if ($ReportPath) {
    $ext = [System.IO.Path]::GetExtension($ReportPath)

    if ($ext -eq ".json") {
        $results | ConvertTo-Json -Depth 10 | Out-File -FilePath $ReportPath -Encoding utf8
    }
    elseif ($ext -eq ".md") {
        $md = @()
        $md += "# CE baseline drift report"
        $md += ""
        $md += "> Generated on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        $md += ""

        foreach ($r in $results | Sort-Object Level, Type, DisplayName) {
            $md += "## $($r.DisplayName)"
            $md += ""
            $md += "- **Level:** $($r.Level)"
            $md += "- **Type:** $($r.Type)"
            $md += "- **Status:** $($r.Status)"
            $md += "- **PolicyId:** $($r.PolicyId)"
            $md += "- **Baseline file:** `$($r.BaselineFile)`"
            $md += ""

            if ($r.Status -eq "Drift" -and $r.Differences.Count -gt 0) {
                $md += "| Property | Baseline | Live |"
                $md += "|----------|----------|------|"
                foreach ($d in $r.Differences) {
                    $b = (Normalize-CeValue $d.BaselineValue)
                    $l = (Normalize-CeValue $d.LiveValue)
                    $md += "| `$($d.PropertyName)` | `$b` | `$l` |"
                }
                $md += ""
            }
        }

        $md -join "`n" | Out-File -FilePath $ReportPath -Encoding utf8
    }
    else {
        # default to JSON
        $results | ConvertTo-Json -Depth 10 | Out-File -FilePath $ReportPath -Encoding utf8
    }

    Write-Host "Drift report written to $ReportPath" -ForegroundColor Green
}
