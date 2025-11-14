# Assignment design – groups and filters (scaffold)

Use **Entra ID dynamic device groups** for coarse targeting and **Intune filters** for version/ownership scoping.

## Example dynamic rules

- Android – Corporate

```text
(device.deviceOSType -eq "Android")
and (device.managementType -eq "MDM")
and (device.deviceOwnership -eq "Company")
```

- Android – BYOD

```text
(device.deviceOSType -eq "Android")
and (device.managementType -eq "MDM")
and (device.deviceOwnership -eq "Personal")
```

- Windows 11 – Corporate

```text
(device.deviceOSType -eq "Windows")
and (device.deviceOSVersion -startsWith "10.0.22")
and (device.managementType -eq "MDM")
and (device.deviceOwnership -eq "Company")
```

## Example filters (Intune)

- Android 14–16 BYOD

```text
(device.deviceOwnership -eq "Personal")
and (device.operatingSystemVersion -ge 14)
and (device.operatingSystemVersion -le 16)
```

- iOS 16.x supervised

```text
(device.isSupervised -eq "true")
and (device.operatingSystemVersion -ge 16)
and (device.operatingSystemVersion -lt 17)
```

Adjust for your actual OS ranges.
