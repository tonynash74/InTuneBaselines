# Cyber Essentials L1 Mapping – Intune Baselines

Version: 1.0  
Scope: Cyber Essentials v3.2 (Willow, April 2025) – *minimum* technical controls for portable devices (Android, iOS/iPadOS, Windows 10/11) managed via Microsoft Intune.

These baselines implement the device-side elements of the five Cyber Essentials technical controls:

- Firewalls
- Secure configuration
- User access control
- Malware protection
- Secure update management

They **do not** cover every CE requirement end-to-end (for example: MFA for cloud services, privileged account management, or vulnerability scanning). Those are handled via Entra ID, M365, and separate infrastructure baselines.

---

## 1. Android

### 1.1 BYOD – Work Profile

**Policy file:** `baselines/L1/android/Android-BYOD-Compliance-Policy.json`  
**Resource type:** `androidWorkProfileCompliancePolicy`

| CE Area                | CE Requirement (summary)                                                      | Intune setting(s)                                                                                               |
|------------------------|-------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| Secure configuration   | Devices must require authentication and auto-lock after inactivity           | `passwordRequired`, `passwordMinimumLength = 6`, `passwordRequiredType = numeric`, `passwordMinutesOfInactivityBeforeLock = 5` |
| Secure configuration   | Protect data at rest                                                         | `storageRequireEncryption = true`                                                                               |
| Malware protection     | Defend against downloaded / installed malware                                | `securityPreventInstallAppsFromUnknownSources = true`, `securityRequireVerifyApps = true`                       |
| Malware protection     | Use platform app-integrity checks where available                            | `securityRequireSafetyNetAttestationBasicIntegrity = true`, `securityRequireSafetyNetAttestationCertifiedDevice = true`, `securityRequireGooglePlayServices = true`, `securityRequireUpToDateSecurityProviders = true`, `securityRequireCompanyPortalAppIntegrity = true` |
| User access control    | Individual user/device access with lock screen                               | Device PIN + auto-lock as above; account-level MFA handled in Entra ID / M365                                   |

### 1.2 Corporate-owned – Fully Managed / COBO / COPE

**Policy file:** `baselines/L1/android/Android-CORP-Compliance-Policy.json`  
**Resource type:** `androidDeviceOwnerCompliancePolicy`

| CE Area                | CE Requirement (summary)                                                      | Intune setting(s)                                                                                               |
|------------------------|-------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| Secure configuration   | Strong authentication and short inactivity lock                               | `passwordRequired = true`, `passwordMinimumLength = 8`, `passwordRequiredType = alphanumeric`, `passwordMinutesOfInactivityBeforeLock = 5`, `passwordPreviousPasswordCountToBlock = 5` |
| Secure configuration   | Protect data at rest                                                         | `storageRequireEncryption = true`                                                                               |
| Malware protection     | Protect against malware and rooted devices                                   | `securityBlockJailbrokenDevices = true`, `securityRequireSafetyNetAttestationBasicIntegrity = true`, `securityRequireSafetyNetAttestationCertifiedDevice = true`, `securityRequireIntuneAppIntegrity = true` |
| Secure update management | Apply security updates promptly                                            | `requireNoPendingSystemUpdates = true`                                                                          |

> **Note:** L1 intentionally does **not** require a third-party MTD agent. `deviceThreatProtectionEnabled = false` and `deviceThreatProtectionRequiredSecurityLevel = "unavailable"` keep this optional. MTD can be added in L2.

---

## 2. iOS / iPadOS

### 2.1 BYOD

**Policy file:** `baselines/L1/ios/iOS-BYOD-Compliance-Policy.json`  
**Resource type:** `iosCompliancePolicy`

| CE Area              | CE Requirement (summary)                                    | Intune setting(s)                                                                                                     |
|----------------------|-------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| Secure configuration | Devices must require authentication and auto-lock           | `passcodeRequired = true`, `passcodeMinimumLength = 6`, `passcodeRequiredType = numeric`, `passcodeBlockSimple = true`, `passcodeMinutesOfInactivityBeforeLock = 5` |
| Secure configuration | Prevent trivial passcodes                                   | `passcodeBlockSimple = true`, `passcodePreviousPasscodeBlockCount = 5`                                               |
| Malware protection   | Jailbroken / rooted devices are not allowed                 | `securityBlockJailbrokenDevices = true`                                                                              |

### 2.2 Corporate-owned / Supervised

**Policy file:** `baselines/L1/ios/iOS-CORP-Compliance-Policy.json`  
**Resource type:** `iosCompliancePolicy`

| CE Area                | CE Requirement (summary)                                  | Intune setting(s)                                                                                                              |
|------------------------|-----------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| Secure configuration   | Stronger authentication on corporate assets               | `passcodeMinimumLength = 8`, `passcodeRequiredType = alphanumeric`, `passcodeMinimumCharacterSetCount = 2`                   |
| Secure configuration   | Stay on supported OS versions                             | `osMinimumVersion = "16.0"`                                                                                                  |
| Malware protection     | Prevent use of jailbroken devices                         | `securityBlockJailbrokenDevices = true`                                                                                      |
| User access control    | Managed access to corporate email                         | `managedEmailProfileRequired = true`                                                                                         |

---

## 3. Windows 10 / 11

### 3.1 Corporate endpoints

**Policy file:** `baselines/L1/windows/Win11-CORP-Compliance-Policy.json`  
**Resource type:** `windows10CompliancePolicy`

| CE Area                  | CE Requirement (summary)                                    | Intune setting(s)                                                                                         |
|--------------------------|-------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| Secure configuration     | Passwords on devices; no simple passwords; idle lock       | `passwordRequired = true`, `passwordBlockSimple = true`, `passwordRequiredToUnlockFromIdle = true`, `passwordMinimumLength = 12`, `passwordMinimumCharacterSetCount = 2`, `passwordRequiredType = alphanumeric`, `passwordMinutesOfInactivityBeforeLock = 10` |
| Secure configuration     | Prevent password reuse                                     | `passwordPreviousPasswordBlockCount = 5`                                                                  |
| Malware protection       | Active anti-malware & secure boot                          | `requireHealthyDeviceReport = true`, `earlyLaunchAntiMalwareDriverEnabled = true`, `codeIntegrityEnabled = true` |
| Secure configuration     | Full-disk encryption                                       | `bitLockerEnabled = true`, `storageRequireEncryption = true`                                             |
| Secure configuration     | Protection from boot-level tampering                       | `secureBootEnabled = true`                                                                               |

> **Note:** L1 does **not** hard-code `osMinimumVersion`. In practice you should either:
> - Use Windows Update for Business / Autopatch to keep devices on supported builds, **and/or**
> - Implement an automated job that updates OS-version-based compliance rules monthly.

---

## 4. Things *not* covered by these L1 baselines

These Intune policies focus on **endpoint configuration**. Cyber Essentials also expects:

- MFA on all cloud services in scope (CE v3.2 makes this explicit).  
- Robust privileged access management and admin account separation.  
- Patch management across all software, not just OS (e.g., third-party apps / browsers).  
- Boundary and host firewalls configured correctly.  

Those are delivered via Entra ID Conditional Access, security baselines, M365 and server/network policies, and will be referenced in higher-level documentation and L2 baselines.

