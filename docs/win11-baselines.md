# Windows 11 baselines (scaffold)

Folders:

- `baselines/L1/windows` – L1 corporate baseline (compliance JSON + config skeleton).
- `baselines/L2/windows` – L2 hardened baseline.

The configuration profile JSONs are skeleton `deviceManagementConfigurationPolicy` objects intended
to be replaced or enriched using a Settings Catalog export from Intune, covering:

- Disk encryption (BitLocker)
- Defender Antivirus
- Firewall
- Attack Surface Reduction
- Local admin control
- Removable media
- Windows Update for Business
