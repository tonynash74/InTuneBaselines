param(
    [Parameter(Mandatory)]
    [ValidateSet("L1","L2")]
    [string]$Level,

    [string]$BaselineRoot = "./baselines",

    [string]$VersionTag = "2025-04"
)

Write-Host "Importing Cyber Essentials $Level baselines (version $VersionTag)..."

. "$PSScriptRoot\Invoke-CeGraphImportPolicy.ps1"
. "$PSScriptRoot\New-CeIosCustomConfiguration.ps1"

$basePath = Join-Path $BaselineRoot $Level

# --- Android ---

$path = Join-Path $basePath "android/Android-BYOD-Compliance-Policy.json"
Invoke-CeGraphImportPolicy -Type Compliance -Path $path `
    -DisplayNameOverride "Android-BYOD-$Level-Compliance-Baseline-$VersionTag"

$path = Join-Path $basePath "android/Android-BYOD-Configuration-Profile.json"
Invoke-CeGraphImportPolicy -Type Configuration -Path $path `
    -DisplayNameOverride "Android-BYOD-$Level-Configuration-Baseline-$VersionTag"

$path = Join-Path $basePath "android/Android-CORP-Compliance-Policy.json"
Invoke-CeGraphImportPolicy -Type Compliance -Path $path `
    -DisplayNameOverride "Android-CORP-$Level-Compliance-Baseline-$VersionTag"

$path = Join-Path $basePath "android/Android-CORP-Configuration-Profile.json"
Invoke-CeGraphImportPolicy -Type Configuration -Path $path `
    -DisplayNameOverride "Android-CORP-$Level-Configuration-Baseline-$VersionTag"

# --- iOS ---

$path = Join-Path $basePath "ios/iOS-BYOD-Compliance-Policy.json"
Invoke-CeGraphImportPolicy -Type Compliance -Path $path `
    -DisplayNameOverride "iOS-BYOD-$Level-Compliance-Baseline-$VersionTag"

$path = Join-Path $basePath "ios/iOS-CORP-Compliance-Policy.json"
Invoke-CeGraphImportPolicy -Type Compliance -Path $path `
    -DisplayNameOverride "iOS-CORP-$Level-Compliance-Baseline-$VersionTag"

$path = Join-Path $basePath "ios/iOS-BYOD-Configuration-Profile.mobileconfig"
New-CeIosCustomConfiguration -Path $path `
    -DisplayName "iOS-BYOD-$Level-Configuration-Baseline-$VersionTag" `
    -Description "Cyber Essentials $Level baseline - BYOD"

$path = Join-Path $basePath "ios/iOS-CORP-Configuration-Profile.mobileconfig"
New-CeIosCustomConfiguration -Path $path `
    -DisplayName "iOS-CORP-$Level-Configuration-Baseline-$VersionTag" `
    -Description "Cyber Essentials $Level baseline - CORP"

# --- Windows 11 ---

$path = Join-Path $basePath "windows/Win11-CORP-Compliance-Policy.json"
Invoke-CeGraphImportPolicy -Type Compliance -Path $path `
    -DisplayNameOverride "Win11-CORP-$Level-Compliance-Baseline-$VersionTag"

$path = Join-Path $basePath "windows/Win11-CORP-Configuration-Profile.json"
Invoke-CeGraphImportPolicy -Type Configuration -Path $path `
    -DisplayNameOverride "Win11-CORP-$Level-Configuration-Baseline-$VersionTag"

Write-Host "Done importing $Level baselines."
