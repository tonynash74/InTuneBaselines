param()

function New-CeIosCustomConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$DisplayName,

        [string]$Description = "Cyber Essentials aligned baseline"
    )

    if (-not (Test-Path $Path)) {
        throw "File not found: $Path"
    }

    $bytes         = Get-Content -Path $Path -Encoding Byte
    $payloadBase64 = [System.Convert]::ToBase64String($bytes)
    $fileName      = [System.IO.Path]::GetFileName($Path)

    $bodyObj = @{
        "@odata.type"   = "#microsoft.graph.iosCustomConfiguration"
        displayName     = $DisplayName
        description     = $Description
        payloadFileName = $fileName
        payloadName     = $DisplayName
        payload         = $payloadBase64
    }

    $bodyJson = $bodyObj | ConvertTo-Json -Depth 10

    $uri = "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations"
    Write-Host "POST $uri using $Path"
    Invoke-MgGraphRequest -Method POST -Uri $uri -Body $bodyJson -ContentType "application/json"
}
