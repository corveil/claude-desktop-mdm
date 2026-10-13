<#
.SYNOPSIS
Writes the 2.7032 profile to HKLM\SOFTWARE\Policies\Claude.

.DESCRIPTION
Sets the values in corveil-2.7032.reg and removes inferenceGatewayOidc,
the original profile's sign-in key that inferenceIdpOidc replaces. Every
other value under the key is left alone.

Run as SYSTEM. Use it as an Intune Win32 app install command, a platform
script, or the remediation script of a remediation.
#>

$ErrorActionPreference = 'Stop'

# Keep in sync with corveil-2.7032.reg and detect.ps1.
$values = [ordered]@{
    inferenceGatewayBaseUrl = 'https://corveil.io'
    inferenceIdpAuthFlow    = 'browser'
    inferenceIdpOidc        = '{"clientId":"client_01KQDHAG1V3FEATNH6YW7MYGXF","authorizationUrl":"https://api.workos.com/user_management/authorize?provider=authkit","tokenUrl":"https://api.workos.com/user_management/authenticate","bearerTokenType":"access_token","scopes":"openid profile email offline_access","appendOfflineAccess":true,"redirectPort":53180,"redirectHost":"127.0.0.1"}'
    inferenceProvider       = 'gateway'
    inferenceCredentialKind = 'external-idp'
}

# Intune runs Win32 app commands in a 32-bit host. Open the 64-bit view
# so the values do not land under WOW6432Node.
$hklm = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Registry64')
try {
    $key = $hklm.CreateSubKey('SOFTWARE\Policies\Claude')
    try {
        $key.DeleteValue('inferenceGatewayOidc', $false)
        foreach ($name in $values.Keys) {
            $key.SetValue($name, $values[$name], 'String')
        }
    } finally {
        $key.Close()
    }
} finally {
    $hklm.Close()
}

Write-Output 'Wrote the Corveil 2.7032 profile to HKLM\SOFTWARE\Policies\Claude.'
