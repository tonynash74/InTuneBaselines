# macOS Cyber Essentials Baselines (L1 & L2)

This folder contains **macOS configuration baselines** aligned with:

- **Cyber Essentials v3.2 (“Willow”, April 2025)** – L1 = minimum controls.
- An **opinionated L2** layer – hardened profiles for high-risk / CE+ style devices.

These config profiles are designed for **corporate-owned / fully managed macOS devices**.  
BYOD Macs are usually better handled with lighter compliance policies + Conditional Access, not full-disk encryption and firewall config.

---

## Folder structure

```text
configuration/
  macos/
    L1/
      ce-l1-macos-general.json
      ce-l1-macos-endpointprotection.json
    L2/
      ce-l2-macos-general.json
      ce-l2-macos-endpointprotection.json
