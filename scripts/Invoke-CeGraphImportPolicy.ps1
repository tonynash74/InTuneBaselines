param()

function Invoke-CeGraphImportPolicy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("Compliance","Configuration")]
        [string]$Type,

        [Parameter(Mandatory)]
        [string]$Path,

        [string]$DisplayNameOverride
    )

    if (-not (Test-Path $Path)) {
        throw "File not found: $Path"
    }

    $bodyJson = Get-Content -Raw -Path $Path
    $bodyObj  = $bodyJson | ConvertFrom-Json

    if ($DisplayNameOverride) {
        $bodyObj.displayName = $DisplayNameOverride
        $bodyJson = $bodyObj | ConvertTo-Json -Depth 20
    }

    switch ($Type) {
        "Compliance" {
            $uri = "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies"
        }
        "Configuration" {
            $uri = "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations"
        }
    }

    Write-Host "POST $uri using $Path"
    Invoke-MgGraphRequest -Method POST -Uri $uri -Body $bodyJson -ContentType "application/json"
}
