param(
    [Parameter(Mandatory)]
    [ValidateSet("L1", "L2")]
    [string]$Level,

    [string]$BaselineRoot = "./baselines",

    [string]$VersionTag = "2025-04"
)

Write-Host "Importing Cyber Essentials $Level baselines (version $VersionTag)..." -ForegroundColor Cyan

# Ensure helper scripts are available
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
    # CE-L1 iOS BYOD – Compliance (2025-04)
    return "CE-$Level $Platform $Scope – $Type ($VersionTag)"
}

# --- Android ---
Write-Host "Importing Android baselines..." -ForegroundColor Yellow

# BYOD
$path = Join-Path $basePath "android/Android-BYOD-Compliance-Policy.json"
Invoke-CeGraphImportPolicy -Type Compliance -Path $path `
    -DisplayNameOverride (New-CeDisplayName -Platform "Android" -Scope "BYOD" -Type "Compliance" -VersionTag $VersionTag -Level $Level)

$path = Join-Path $basePath "android/Android-BYOD-Configuration-Profile.json"
Invoke-CeGraphImportPolicy -Type Configuration -Path $path `
    -DisplayNameOverride (New-CeDisplayName -Platform "Android" -Scope "BYOD" -Type "Config" -VersionTag $VersionTag -Level $Level)

# CORP
$path = Join-Path $basePath "android/Android-CORP-Compliance-Policy.json"
Invoke-CeGraphImportPolicy -Type Compliance -Path $path `
    -DisplayNameOverride (New-CeDisplayName -Platform "Android" -Scope "CORP" -Type "Compliance" -VersionTag $VersionTag -Level $Level)

$path = Join-Path $basePath "android/Android-CORP-Configuration-Profile.json"
Invoke-CeGraphImportPolicy -Type Configuration -Path $path `
    -DisplayNameOverride (New-CeDisplayName -Platform "Android" -Scope "CORP" -Type "Config" -VersionTag $VersionTag -Level $Level)

# --- iOS ---
Write-Host "Importing iOS/iPadOS baselines..." -ForegroundColor Yellow

# Compliance (BYOD / CORP) – already JSON in baselines
$path = Join-Path $basePath "ios/iOS-BYOD-Compliance-Policy.json"
Invoke-CeGraphImportPolicy -Type Compliance -Path $path `
    -DisplayNameOverride (New-CeDisplayName -Platform "iOS" -Scope "BYOD" -Type "Compliance" -VersionTag $VersionTag -Level $Level)

$path = Join-Path $basePath "ios/iOS-CORP-Compliance-Policy.json"
Invoke-CeGraphImportPolicy -Type Compliance -Path $path `
    -DisplayNameOverride (New-CeDisplayName -Platform "iOS" -Scope "CORP" -Type "Compliance" -VersionTag $VersionTag -Level $Level)

# Configuration (now Graph-native iosGeneralDeviceConfiguration)
$path = Join-Path $basePath "ios/iOS-BYOD-Configuration-Profile.json"
if (Test-Path $path) {
    Invoke-CeGraphImportPolicy -Type Configuration -Path $path `
        -DisplayNameOverride (New-CeDisplayName -Platform "iOS" -Scope "BYOD" -Type "Config" -VersionTag $VersionTag -Level $Level)
}
else {
    Write-Warning "Expected iOS BYOD configuration JSON not found at $path"
}

$path = Join-Path $basePath "ios/iOS-CORP-Configuration-Profile.json"
if (Test-Path $path) {
    Invoke-CeGraphImportPolicy -Type Configuration -Path $path `
        -DisplayNameOverride (New-CeDisplayName -Platform "iOS" -Scope "CORP" -Type "Config" -VersionTag $VersionTag -Level $Level)
}
else {
    Write-Warning "Expected iOS CORP configuration JSON not found at $path"
}

# --- Windows 11 ---
Write-Host "Importing Windows 11 baselines..." -ForegroundColor Yellow

$path = Join-Path $basePath "windows/Win11-CORP-Compliance-Policy.json"
Invoke-CeGraphImportPolicy -Type Compliance -Path $path `
    -DisplayNameOverride (New-CeDisplayName -Platform "Windows 11" -Scope "CORP" -Type "Compliance" -VersionTag $VersionTag -Level $Level)

$path = Join-Path $basePath "windows/Win11-CORP-Configuration-Profile.json"
Invoke-CeGraphImportPolicy -Type Configuration -Path $path `
    -DisplayNameOverride (New-CeDisplayName -Platform "Windows 11" -Scope "CORP" -Type "Config" -VersionTag $VersionTag -Level $Level)

Write-Host "Done importing $Level baselines." -ForegroundColor Green
