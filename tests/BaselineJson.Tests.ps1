param()

$repoRoot = Split-Path -Parent $PSScriptRoot
$baselinesRoot = Join-Path $repoRoot "baselines"

Describe "Baseline JSON validity" {
    It "Baselines folder exists" {
        Test-Path $baselinesRoot | Should -BeTrue
    }

    $jsonFiles = Get-ChildItem -Path $baselinesRoot -Recurse -Filter "*.json" -ErrorAction SilentlyContinue

    foreach ($file in $jsonFiles) {
        It "parses as valid JSON: $($file.FullName)" {
            $content = Get-Content -Raw -Path $file.FullName
            { $content | ConvertFrom-Json } | Should -Not -Throw
        }

        It "has @odata.type and displayName: $($file.Name)" {
            $content = Get-Content -Raw -Path $file.FullName
            $obj = $content | ConvertFrom-Json

            $obj.'@odata.type' | Should -Not -BeNullOrEmpty
            $obj.displayName | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "L1/L2 baseline symmetry" {
    $l1Root = Join-Path $baselinesRoot "L1"
    $l2Root = Join-Path $baselinesRoot "L2"

    It "L1 folder exists" {
        Test-Path $l1Root | Should -BeTrue
    }

    It "L2 folder exists" {
        Test-Path $l2Root | Should -BeTrue
    }

    $l1Files = Get-ChildItem -Path $l1Root -Recurse -Filter "*.json" -ErrorAction SilentlyContinue

    foreach ($file in $l1Files) {
        $relativePath = $file.FullName.Substring($l1Root.Length).TrimStart('\','/')
        $l2Path = Join-Path $l2Root $relativePath

        It "L2 counterpart exists for $relativePath" {
            Test-Path $l2Path | Should -BeTrue
        }
    }
}
