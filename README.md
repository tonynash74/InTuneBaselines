# Cyber Essentials Aligned Intune Baselines

This repo contains **Intune baselines** aligned with **Cyber Essentials v3.2 (“Willow”, April 2025)**:

- **L1** – minimum Cyber Essentials controls.
- **L2** – hardened overlay for high-risk devices / CE+ style posture.

Platforms:

- Android (BYOD + Corporate)
- iOS/iPadOS (BYOD + Corporate)
- Windows 11 (Corporate)
- macOS (Corporate; BYOD handled separately)

Baselines are expressed as **Microsoft Graph JSON** and deployed using PowerShell scripts in `scripts/`.

---

## Structure

baselines/
  L1/
    android/
    ios/
      iOS-BYOD-Compliance-Policy.json
      iOS-BYOD-Configuration-Profile.json
      iOS-CORP-Compliance-Policy.json
      iOS-CORP-Configuration-Profile.json
    windows/
    macos/
      macOS-CORP-Compliance-Policy.json

  L2/
    android/
    ios/
      iOS-BYOD-Compliance-Policy.json
      iOS-BYOD-Configuration-Profile.json
      iOS-CORP-Compliance-Policy.json
      iOS-CORP-Configuration-Profile.json
    windows/
    macos/
      macOS-CORP-Compliance-Policy.json


## PowerShell module usage

For a more ergonomic experience, use the module wrapper:

```powershell
Import-Module .\modules\Ce.IntuneBaselines\Ce.IntuneBaselines.psd1

# Import baselines for the current tenant
Import-CeBaseline -Level L1 -VersionTag "2025-04"
Import-CeBaseline -Level L2 -VersionTag "2025-04"

# Check for drift between repo baselines and Intune
Compare-CeBaselines -Level All -ReportPath .\reports\drift-all.md

# Summarise CE readiness in the current tenant
Get-CeTenantReadiness | Format-Table

# Multi-tenant rollout
Invoke-CeBaselineDeployment -TenantConfigPath .\tenants\tenants.json -WhatIf
