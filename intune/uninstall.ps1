<#
.SYNOPSIS
Removes the 2.7032 profile from HKLM\SOFTWARE\Policies\Claude.

.DESCRIPTION
Deletes the values that install.ps1 sets. Every other value under the key
is left alone. Use it as an Intune Win32 app uninstall command.
#>

$ErrorActionPreference = 'Stop'

$names = @(
    'inferenceGatewayBaseUrl'
    'inferenceIdpAuthFlow'
    'inferenceIdpOidc'
    'inferenceProvider'
    'inferenceCredentialKind'
)

$hklm = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Registry64')
try {
    $key = $hklm.OpenSubKey('SOFTWARE\Policies\Claude', $true)
    if ($null -ne $key) {
        try {
            foreach ($name in $names) {
                $key.DeleteValue($name, $false)
            }
        } finally {
            $key.Close()
        }
    }
} finally {
    $hklm.Close()
}

Write-Output 'Removed the Corveil 2.7032 profile from HKLM\SOFTWARE\Policies\Claude.'
