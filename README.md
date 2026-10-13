# Claude Desktop MDM profile for Corveil

Sample managed configuration that points Claude Desktop at the hosted
Corveil gateway and signs the user in through the organization identity
provider.

## Which profile to use

Claude Desktop 2.7032.0 renamed the keys that configure this sign-in.
Both spellings sign the user in the same way.

| Your devices | Use |
| --- | --- |
| Any device on a release before 2.7032.0, or you are not sure | The original profile. It works on Claude Desktop 1.6889.0 and later. |
| Every device on Claude Desktop 2.7032.0 or later | The 2.7032 profile. It uses the current key names. |

The original names are deprecated, but Claude Desktop still reads them
and Anthropic has not set an end date. Releases before 2.7032.0 do not
read the new names, so the 2.7032 profile does not sign users in on
them.

Deploy one profile per device. On macOS, a user-scope profile overrides
a device-scope profile key by key, so installing both mixes them.

## Original profile

The four files encode the same keys.

| File | Where it goes |
| --- | --- |
| `corveil.mobileconfig` | macOS MDM, device scope. Payload domain `com.anthropic.claudefordesktop`. |
| `corveil.reg` | Windows. Values directly under `HKLM\SOFTWARE\Policies\Claude`. |
| `managed-settings.json` | Linux. Install at `/etc/claude-desktop/managed-settings.json`. |
| `corveil.json` | The same profile as JSON. |

Sign-in sets `inferenceCredentialKind` to `interactive` and supplies
`inferenceGatewayOidc`. `inferenceGatewayOidc` and `banner` are one JSON
string in the `.mobileconfig` and the `.reg`. On Windows,
`chatTabEnabled` and `endUserAttribution` are `DWORD` values.

`deploymentDisplayName`, `deploymentDisplaySubtitle`, and the banner text
are sample labels. Replace them before you deploy.

## 2.7032 profile

| File | Where it goes |
| --- | --- |
| `corveil-2.7032.mobileconfig` | macOS MDM, user scope. Payload domain `com.anthropic.claudefordesktop`. |
| `corveil-2.7032.reg` | Windows. Values directly under `HKLM\SOFTWARE\Policies\Claude`. |

Sign-in sets `inferenceCredentialKind` to `external-idp` and supplies
`inferenceIdpOidc`, with `inferenceIdpAuthFlow` set to `browser`.
`inferenceIdpOidc` is one JSON string in both files.

These files set only the gateway and sign-in keys. They leave the chat
tab, the deployment labels, end-user attribution, and the banner at
their defaults. There is no Linux or JSON form of this profile.

Both Windows files write machine policy, the hive Anthropic recommends
for a fleet. Importing a `.reg` file adds and overwrites values but
never removes them. To move a Windows device from `corveil.reg` to
`corveil-2.7032.reg`, clear the key first with
`reg delete HKLM\SOFTWARE\Policies\Claude /va /f`. Otherwise the
original profile's banner, labels, chat tab, attribution, and
`inferenceGatewayOidc` stay on the device.

Claude Desktop ignores `HKCU\SOFTWARE\Policies\Claude` when any value
is present under `HKLM\SOFTWARE\Policies\Claude`, so do not split a
profile across the two hives.

## Intune

Intune cannot import a `.reg` file. The scripts in `intune/` write the
2.7032 profile to `HKLM\SOFTWARE\Policies\Claude`, and Intune runs each
one as uploaded.

| File | What it does |
| --- | --- |
| `intune/install.ps1` | Sets the values in `corveil-2.7032.reg` and removes `inferenceGatewayOidc`, the sign-in key they replace. Leaves every other value under the key alone. |
| `intune/detect.ps1` | Exits 0 when every value is set as in `corveil-2.7032.reg` and `inferenceGatewayOidc` is gone. Otherwise exits 1 and names the values that differ. |
| `intune/uninstall.ps1` | Removes the values that `install.ps1` sets. |

All three run as SYSTEM and open the 64-bit registry view themselves,
so the values land in the right place from either PowerShell host.

Deploy them one of these ways:

- **Win32 app.** Package the `intune` folder with the Microsoft Win32
  Content Prep Tool (`IntuneWinAppUtil.exe`).
  - Install command:
    `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1`
  - Uninstall command:
    `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\uninstall.ps1`
  - Install behavior: System.
  - Detection rule: use a custom detection script and upload
    `detect.ps1`.
- **Remediation.** Detection script `detect.ps1`, remediation script
  `install.ps1`, with "Run this script using the logged-on credentials"
  set to No. Intune puts the values back on its schedule if they change.
  Remediations need a license that includes them, such as Windows
  Enterprise E3 or E5.
- **Platform script.** Upload `install.ps1` and leave "Run this script
  using the logged on credentials" at No. It runs once, so nothing puts
  the values back if they are removed later.

On a device that had `corveil.reg`, `install.ps1` replaces the sign-in
but keeps the original profile's banner, labels, chat tab, and
attribution. Clear the key first if you do not want them.

The scripts deploy only the 2.7032 profile. For devices on a release
before 2.7032.0, package `corveil.reg` as a Win32 app instead:

- Install command: `reg import corveil.reg /reg:64`
- Uninstall command: `reg delete HKLM\SOFTWARE\Policies\Claude /va /f /reg:64`.
  This removes every value under the key.
- Install behavior: System.
- Detection rule: registry, key `HKLM\SOFTWARE\Policies\Claude`, value
  `inferenceCredentialKind`, string comparison equals `interactive`,
  with "Associated with a 32-bit app on 64-bit clients" set to No.

`install.ps1` and `detect.ps1` each carry a copy of the values in
`corveil-2.7032.reg`. Change all three files together.

None of these files contains an API key or a session token.

Setup notes: <https://corveil.com/docs/clients/claude-desktop-mdm>
