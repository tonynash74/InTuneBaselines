```markdown
# Runbook: Upgrade a tenant from CE L1 to CE L2

Audience: 2nd/3rd line engineers.

Goal: Add **L2 (hardened) baselines** for high-risk devices (admins, security, privileged roles) on top of existing L1 rollout.

---

## 1. Identify L2 scope

Work with the customer to identify:

- Admin / IT teams.
- Security and compliance staff.
- Devices handling sensitive data.

Create (or confirm) device/user groups such as:

- `SEC-CE-L2-Android-CORP`
- `SEC-CE-L2-iOS-CORP`
- `SEC-CE-L2-Win11-CORP`
- `SEC-CE-L2-macOS-CORP`

These should be **subsets** of the corresponding L1 groups.

---

## 2. Import L2 baselines

If not already present, import L2 baselines:

```powershell
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All"

.\scripts\Import-IntuneBaselines.ps1 -Level L2 -VersionTag "2025-04"