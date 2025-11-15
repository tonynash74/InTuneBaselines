[CmdletBinding()]
param(
    [string]$VersionTag = "2025-04",

    [switch]$AsJson
)

<#
.SYNOPSIS
    Summarise CE L1/L2 baseline coverage and assignment for the current tenant.

.DESCRIPTION
    Searches Intune for policies whose displayName follows:

      CE-L<Level> <Platform> <Scope> – <Type> (<VersionTag>)

    and reports whether each expected baseline exists and is assigned.

    Expected baselines (per tenant):
      - Android BYOD: L1/L2, Compliance+Config
      - Android CORP: L1/L2, Compliance+Config
      - iOS BYOD: L1/L2, Compliance+Config
      - iOS CORP: L1/L2, Compliance+Config
      - Windows 11 CORP: L1/L2, Compliance+Config
      - macOS CORP: L1/L2, Compliance+Compliance-only (config may be separate)

.REQUIREMENTS
    - Microsoft Graph PowerShell SDK
    - Connect-MgGraph -Scopes "DeviceManagementConfiguration.Read.All"
#>

function New-CeNameBase {
    param(
        [Parameter(Mandatory)][string]$Level,
        [Parameter(Mandatory)][string]$Platform,
        [Parameter(Mandatory)][string]$Scope,
        [Parameter(Mandatory)][ValidateSet("Compliance", "Config")]
        [string]$Type
    )
    # CE-L1 Android BYOD – Compliance
    return "CE-$Level $Platform $Scope – $Type"
}

$expected = @(
    # Android
    @{ Level = "L1"; Platform = "Android"; Scope = "BYOD"; Type = "Compliance" }
    @{ Level = "L1"; Platform = "Android"; Scope = "BYOD"; Type = "Config"     }
    @{ Level = "L1"; Platform = "Android"; Scope = "CORP"; Type = "Compliance" }
    @{ Level = "L1"; Platform = "Android"; Scope = "CORP"; Type = "Config"     }

    @{ Level = "L2"; Platform = "Android"; Scope = "BYOD"; Type = "Compliance" }
    @{ Level = "L2"; Platform = "Android"; Scope = "BYOD"; Type = "Config"     }
    @{ Level = "L2"; Platform = "Android"; Scope = "CORP"; Type = "Compliance" }
    @{ Level = "L2"; Platform = "Android"; Scope = "CORP"; Type = "Config"     }

    # iOS
    @{ Level = "L1"; Platform = "iOS"; Scope = "BYOD"; Type = "Compliance"     }
    @{ Level = "L1"; Platform = "iOS"; Scope = "BYOD"; Type = "Config"         }
    @{ Level = "L1"; Platform = "iOS"; Scope = "CORP"; Type = "Compliance"     }
    @{ Level = "L1"; Platform = "iOS"; Scope = "CORP"; Type = "Config"         }

    @{ Level = "L2"; Platform = "iOS"; Scope = "BYOD"; Type = "Compliance"     }
    @{ Level = "L2"; Platform = "iOS"; Scope = "BYOD"; Type = "Config"         }
    @{ Level = "L2"; Platform = "iOS"; Scope = "CORP"; Type = "Compliance"     }
    @{ Level = "L2"; Platform = "iOS"; Scope = "CORP"; Type = "Config"         }

    # Windows 11 CORP
    @{ Level = "L1"; Platform = "Windows 11"; Scope = "CORP"; Type = "Compliance" }
    @{ Level = "L1"; Platform = "Windows 11"; Scope = "CORP"; Type = "Config"     }
    @{ Level = "L2"; Platform = "Windows 11"; Scope = "CORP"; Type = "Compliance" }
    @{ Level = "L2"; Platform = "Windows 11"; Scope = "CORP"; Type = "Config"     }

    # macOS CORP (compliance only in this matrix)
    @{ Level = "L1"; Platform = "macOS"; Scope = "CORP"; Type = "Compliance" }
    @{ Level = "L2"; Platform = "macOS"; Scope = "CORP"; Type = "Compliance" }
)

Write-Host "Fetching Intune policies..." -ForegroundColor Cyan

$compliancePolicies = Get-MgDeviceManagementDeviceCompliancePolicy -All -ErrorAction SilentlyContinue
$configPolicies     = Get-MgDeviceManagementDeviceConfiguration -All -ErrorAction SilentlyContinue

$result = @()

foreach ($item in $expected) {
    $level    = $item.Level
    $platform = $item.Platform
    $scope    = $item.Scope
    $type     = $item.Type

    $nameBase = New-CeNameBase -Level $level -Platform $platform -Scope $scope -Type $type

    if ($type -eq "Compliance") {
        $candidates = $compliancePolicies |
            Where-Object { $_.displayName -like "$nameBase*" }
    } else {
        $candidates = $configPolicies |
            Where-Object { $_.displayName -like "$nameBase*" }
    }

    $found = $false
    $assigned = $false
    $policyId = $null
    $policyDisplayName = $null
    $assignmentCount = 0

    if ($candidates) {
        # Prefer the one with the latest lastModifiedDateTime
        $policy = $candidates |
            Sort-Object -Property lastModifiedDateTime -Descending |
            Select-Object -First 1

        $found = $true
        $policyId = $policy.id
        $policyDisplayName = $policy.displayName

        try {
            if ($type -eq "Compliance") {
                $assignUri = "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies/$($policy.id)/assignments"
            }
            else {
                $assignUri = "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations/$($policy.id)/assignments"
            }

            $assignResp = Invoke-MgGraphRequest -Method GET -Uri $assignUri -ErrorAction SilentlyContinue
            if ($assignResp.value) {
                $assignmentCount = $assignResp.value.Count
                $assigned = $assignmentCount -gt 0
            }
        }
        catch {
            Write-Warning "Failed to query assignments for $($policy.displayName): $_"
        }
    }

    $result += [pscustomobject]@{
        Level             = $level
        Platform          = $platform
        Scope             = $scope
        Type              = $type
        ExpectedNameBase  = $nameBase
        Found             = $found
        Assigned          = $assigned
        PolicyId          = $policyId
        PolicyDisplayName = $policyDisplayName
        AssignmentCount   = $assignmentCount
        VersionTag        = $VersionTag
    }
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 5
}
else {
    $result |
        Sort-Object Level, Platform, Scope, Type |
        Format-Table -AutoSize
}
