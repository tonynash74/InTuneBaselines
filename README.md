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
configuration/
  macos/
    L1/
    L2/
scripts/
.github/
docs/
tenants/
