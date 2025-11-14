# Cyber Essentials Aligned Intune Baselines

This repository contains scaffolded **L1** and **L2** baselines for:

- Android (BYOD + Corporate)
- iOS (BYOD + Corporate)
- Windows 11 (Corporate)

The structure separates **L1** (minimum Cyber Essentials-aligned baseline) and **L2** (hardened) by folder.
JSON files are intended to be used with **Microsoft Graph** via the PowerShell scripts in `scripts/`.

> Note: Android L1 baselines in this scaffold contain example Graph JSON payloads. Other baselines may be minimal
> skeletons for now and should be validated and extended before production use.

## Structure

```text
baselines/
  L1/
    android/
    ios/
    windows/
  L2/
    android/
    ios/
    windows/
scripts/
.github/workflows/
docs/
```

## Importing baselines

1. Connect to Graph with `DeviceManagementConfiguration.ReadWrite.All`.
2. Run:

```powershell
.\scripts\Import-IntuneBaselines.ps1 -Level L1 -VersionTag "2025-04"
.\scripts\Import-IntuneBaselines.ps1 -Level L2 -VersionTag "2025-04"
```

3. Assign policies in Intune using the dynamic groups and filters described in `docs/assignment-design.md`.
