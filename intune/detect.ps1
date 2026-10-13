<#
.SYNOPSIS
Checks for the 2.7032 profile under HKLM\SOFTWARE\Policies\Claude.

.DESCRIPTION
Exits 0 and writes a line to STDOUT when every value in corveil-2.7032.reg
is present as a string with the expected data and inferenceGatewayOidc is
absent. Otherwise exits 1 and names the values that differ.

Use it as an Intune Win32 app custom detection script or the detection
script of a remediation.
#>

$ErrorActionPreference = 'Stop'

# Keep in sync with corveil-2.7032.reg and install.ps1.
$values = [ordered]@{
    inferenceGatewayBaseUrl = 'https://corveil.io'
    inferenceIdpAuthFlow    = 'browser'
    inferenceIdpOidc        = '{"clientId":"client_01KQDHAG1V3FEATNH6YW7MYGXF","authorizationUrl":"https://api.workos.com/user_management/authorize?provider=authkit","tokenUrl":"https://api.workos.com/user_management/authenticate","bearerTokenType":"access_token","scopes":"openid profile email offline_access","appendOfflineAccess":true,"redirectPort":53180,"redirectHost":"127.0.0.1"}'
    inferenceProvider       = 'gateway'
    inferenceCredentialKind = 'external-idp'
}

$hklm = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Registry64')
try {
    $key = $hklm.OpenSubKey('SOFTWARE\Policies\Claude')
    if ($null -eq $key) {
        Write-Output 'HKLM\SOFTWARE\Policies\Claude does not exist.'
        exit 1
    }
    try {
        $present = $key.GetValueNames()
        $differ = @(foreach ($name in $values.Keys) {
            if ($present -notcontains $name -or
                $key.GetValueKind($name) -ne 'String' -or
                $key.GetValue($name) -cne $values[$name]) {
                $name
            }
        })
        if ($present -contains 'inferenceGatewayOidc') {
            $differ += 'inferenceGatewayOidc'
        }
    } finally {
        $key.Close()
    }
} finally {
    $hklm.Close()
}

if ($differ.Count -gt 0) {
    Write-Output "Values that differ from the 2.7032 profile: $($differ -join ', ')"
    exit 1
}

Write-Output 'The Corveil 2.7032 profile is set.'
exit 0
