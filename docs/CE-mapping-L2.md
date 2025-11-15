# Cyber Essentials L2 Baseline – Windows 11

> L2 = “hardened” superset of the Cyber Essentials (CE) minimum controls (L1).  
> It is designed for higher risk / CE+ style environments while remaining practical for MSP use.

## Scope

- Platform: Windows 11 (Windows 10 and later in Intune)
- Ownership: Corporate devices only
- Profiles:
  - `Win11-CORP-Compliance-Policy` (L2)
  - `Win11-CORP-Configuration-Profile` (L2 – Endpoint Protection)

## Control mapping (summary)

| CE Control Area              | Intune Object Type                                  | Key Settings (L2)                                                                                              | Notes                                                                                                    |
|-----------------------------|-----------------------------------------------------|----------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| Firewalls                   | Endpoint Protection config (`windows10EndpointProtectionConfiguration`) | `firewallProfile*.*firewallEnabled = allowed`<br>`inboundConnectionsBlocked = true`<br>`stealthModeBlocked = true` | Enforces host firewall on all profiles, blocks inbound by default, and hides device from simple scans.  |
| Secure configuration        | Endpoint Protection config                          | Disable Guest + built-in Admin account<br>Block anonymous SAM enumeration<br>Block Microsoft accounts           | Reduces local account / identity attack surface; aligns with NCSC secure config guidance.               |
| User access control         | Compliance policy (`windows10CompliancePolicy`)     | Password length 14, char sets 3, lock after 5 minutes                                                          | Stronger than L1 while still workable for typical corporate endpoints.                                   |
| Malware protection          | Endpoint Protection config                          | Defender real-time/on-access enabled<br>Cloud protection + high block level<br>PUA + network protection enabled | Satisfies CE requirements for AV and extends into CE+ style network/PUA protection.                     |
| Security update management  | Compliance policy + separate WUfB policies (TBD)    | `osMinimumVersion = 10.0.22000.0` (Windows 11)<br>BitLocker, SecureBoot, CodeIntegrity, storage encryption      | Ensures only supported Windows builds are compliant and core platform protections are enabled.          |

## Usage notes

- **L1 vs L2**  
  - L1: Minimum CE-aligned controls for all managed Windows endpoints.  
  - L2: Harsher baseline for high-value assets or where CE+ / external tests are expected.

- **Assignment strategy**  
  - Assign L2 policies to dedicated AAD groups (for example, `SEC-CE-L2-Win11-Corp`) to allow gradual rollout.
  - Keep L1 in place as a guard-rail; L2 should be viewed as an overlay, not a replacement, for most orgs.

- **Compatibility considerations**  
  - Some L2 changes (for example disabling built-in Administrator or blocking consumer Microsoft accounts) may conflict with legacy workflows.  
  - Pilot L2 on a small, representative group before broad deployment.
