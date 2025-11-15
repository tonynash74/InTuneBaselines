# Settings Catalog explorer (Get-CeIntuneSettingsCatalog.ps1)

This script is a **read-only helper** around the Intune **Settings Catalog**, using the
`deviceManagementConfigurationPolicy` and `/settings` endpoints on the Graph **beta** API.   

Use it to:

- Discover policies and templates.
- Search for settings (e.g. "BitLocker", "Firewall").
- Export policies + settings to JSON / Markdown for offline analysis and repo storage.

## Requirements

- Microsoft Graph PowerShell SDK
- Permissions:
  - `DeviceManagementConfiguration.Read.All` (minimum)   

## Examples

```powershell
# Connect to Graph (delegated)
Connect-MgGraph -Scopes "DeviceManagementConfiguration.Read.All"

# List all Settings Catalog policies for Windows
.\scripts\Get-CeIntuneSettingsCatalog.ps1 -Platform windows10

# Search for 'BitLocker' across all platforms
.\scripts\Get-CeIntuneSettingsCatalog.ps1 -Search BitLocker

# Export macOS policies with settings to JSON + Markdown
.\scripts\Get-CeIntuneSettingsCatalog.ps1 `
  -Platform macOS `
  -IncludeSettings `
  -ExportJsonPath ./settings-catalog/raw `
  -ExportMarkdownPath ./settings-catalog/docs/index.md
