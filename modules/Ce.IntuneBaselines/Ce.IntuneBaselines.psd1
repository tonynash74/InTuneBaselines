@{
    RootModule        = 'Ce.IntuneBaselines.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '11111111-2222-3333-4444-555555555555'
    Author            = 'Your MSP'
    CompanyName       = 'Your MSP'
    Copyright         = '(c) Your MSP'
    Description       = 'Helpers for deploying and validating Cyber Essentials aligned Intune baselines.'
    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Import-CeBaseline',
        'Invoke-CeBaselineDeployment',
        'Get-CeSettingsCatalog',
        'Compare-CeBaselines',
        'Get-CeTenantReadiness'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
