param(
    [Parameter(Mandatory)]
    [ValidateSet("L1", "L2")]
    [string]$Level,

    [string]$BaselineRoot = "./baselines",

    [string]$VersionTag = "2025-04",

    # NEW: filter which policies to import
    [ValidateSet("Android", "iOS", "Windows 11", "macOS")]
    [string[]]$Platforms = @("Android", "iOS", "Windows 11", "macOS"),

    [ValidateSet("BYOD", "CORP")]
    [string[]]$Scopes = @("BYOD", "CORP"),

    [ValidateSet("Compliance", "Config")]
    [string[]]$Types = @("Compliance", "Config")
)

Write-Host "Importing Cyber Essentials $Level baselines (version $VersionTag)..." -ForegroundColor Cyan

# Ensure helper script is available
. "$PSScriptRoot\Invoke-CeGraphImportPolicy.ps1"
if (Test-Path "$PSScriptRoot\New-CeIosCustomConfiguration.ps1") {
    . "$PSScriptRoot\New-CeIosCustomConfiguration.ps1"
}

$basePath = Join-Path $BaselineRoot $Level

function New-CeDisplayName {
    param(
        [Parameter(Mandatory)][string]$Platform,
        [Parameter(Mandatory)][string]$Scope,
        [Parameter(Mandatory)][ValidateSet("Compliance", "Config")]
        [string]$Type,
        [Parameter(Mandatory)][string]$VersionTag,
        [Parameter(Mandatory)][string]$Level
    )
    # CE-L1 Android BYOD – Compliance (2025-04)
    return "CE-$Level $Platform $Scope – $Type ($VersionTag)"
}

function Import-CePolicy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("Compliance", "Config")]
        [string]$Type,

        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Platform,

        [Parameter(Mandatory)]
        [string]$Scope,

        [Parameter(Mandatory)]
        [string]$Level,

        [Parameter(Mandatory)]
        [string]$VersionTag
    )

    if (-not (Test-Path $Path)) {
        Write-Warning "Baseline file not found, skipping: $Path"
        return
    }

    $graphType = if ($Type -eq "Compliance") { "Compliance" } else { "Configuration" }

    $displayName = New-CeDisplayName -Platform $Platform -Scope $Scope -Type $Type -VersionTag $VersionTag -Level $Level

    Write-Host "Importing $Type baseline for $Platform $Scope from $Path" -ForegroundColor Yellow

    Invoke-CeGraphImportPolicy -Type $graphType -Path $Path -DisplayNameOverride $displayName
}

#
# ANDROID
#
if ("Android" -in $Platforms) {
    Write-Host "Processing Android baselines..." -ForegroundColor Cyan

    if ("BYOD" -in $Scopes) {
        if ("Compliance" -in $Types) {
            $path = Join-Path $basePath "android/Android-BYOD-Compliance-Policy.json"
            Import-CePolicy -Type "Compliance" -Path $path -Platform "Android" -Scope "BYOD" -Level $Level -VersionTag $VersionTag
        }
        if ("Config" -in $Types) {
            $path = Join-Path $basePath "android/Android-BYOD-Configuration-Profile.json"
            Import-CePolicy -Type "Config" -Path $path -Platform "Android" -Scope "BYOD" -Level $Level -VersionTag $VersionTag
        }
    }

    if ("CORP" -in $Scopes) {
        if ("Compliance" -in $Types) {
            $path = Join-Path $basePath "android/Android-CORP-Compliance-Policy.json"
            Import-CePolicy -Type "Compliance" -Path $path -Platform "Android" -Scope "CORP" -Level $Level -VersionTag $VersionTag
        }
        if ("Config" -in $Types) {
            $path = Join-Path $basePath "android/Android-CORP-Configuration-Profile.json"
            Import-CePolicy -Type "Config" -Path $path -Platform "Android" -Scope "CORP" -Level $Level -VersionTag $VersionTag
        }
    }
}

#
# iOS / iPadOS
#
if ("iOS" -in $Platforms) {
    Write-Host "Processing iOS/iPadOS baselines..." -ForegroundColor Cyan

    if ("BYOD" -in $Scopes) {
        if ("Compliance" -in $Types) {
            $path = Join-Path $basePath "ios/iOS-BYOD-Compliance-Policy.json"
            Import-CePolicy -Type "Compliance" -Path $path -Platform "iOS" -Scope "BYOD" -Level $Level -VersionTag $VersionTag
        }
        if ("Config" -in $Types) {
            $path = Join-Path $basePath "ios/iOS-BYOD-Configuration-Profile.json"
            Import-CePolicy -Type "Config" -Path $path -Platform "iOS" -Scope "BYOD" -Level $Level -VersionTag $VersionTag
        }
    }

    if ("CORP" -in $Scopes) {
        if ("Compliance" -in $Types) {
            $path = Join-Path $basePath "ios/iOS-CORP-Compliance-Policy.json"
            Import-CePolicy -Type "Compliance" -Path $path -Platform "iOS" -Scope "CORP" -Level $Level -VersionTag $VersionTag
        }
        if ("Config" -in $Types) {
            $path = Join-Path $basePath "ios/iOS-CORP-Configuration-Profile.json"
            Import-CePolicy -Type "Config" -Path $path -Platform "iOS" -Scope "CORP" -Level $Level -VersionTag $VersionTag
        }
    }
}

#
# WINDOWS 11 (CORP only)
#
if ("Windows 11" -in $Platforms -and "CORP" -in $Scopes) {
    Write-Host "Processing Windows 11 baselines..." -ForegroundColor Cyan

    if ("Compliance" -in $Types) {
        $path = Join-Path $basePath "windows/Win11-CORP-Compliance-Policy.json"
        Import-CePolicy -Type "Compliance" -Path $path -Platform "Windows 11" -Scope "CORP" -Level $Level -VersionTag $VersionTag
    }
    if ("Config" -in $Types) {
        $path = Join-Path $basePath "windows/Win11-CORP-Configuration-Profile.json"
        Import-CePolicy -Type "Config" -Path $path -Platform "Windows 11" -Scope "CORP" -Level $Level -VersionTag $VersionTag
    }
}

#
# macOS (CORP only) – compliance baselines
#
if ("macOS" -in $Platforms -and "CORP" -in $Scopes) {
    Write-Host "Processing macOS baselines..." -ForegroundColor Cyan

    if ("Compliance" -in $Types) {
        $path = Join-Path $basePath "macos/macOS-CORP-Compliance-Policy.json"
        Import-CePolicy -Type "Compliance" -Path $path -Platform "macOS" -Scope "CORP" -Level $Level -VersionTag $VersionTag
    }
}

Write-Host "Done importing $Level baselines." -ForegroundColor Green
