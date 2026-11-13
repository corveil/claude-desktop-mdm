# Claude Desktop MDM profile for Corveil

Sample managed configuration that points Claude Desktop at the hosted
Corveil gateway and signs the user in through the organization identity
provider.

> [!WARNING]
> Every template's sign-in URL ends in the placeholder
> `organization_id=YOUR_ORGANIZATION_ID`. Earlier versions of these
> files used `provider=authkit` and worked unchanged. If you redeploy
> from this repository, replace the placeholder in every file you use
> first, including both Intune scripts. Every device that gets a file
> with the placeholder still in it fails to sign in. Your organization's
> download from Corveil has it filled in.

## Download your organization's profile

These files are templates. Get your organization's copy from Corveil
instead: on **People & Access → Organization**, choose **Get Desktop
profile** on the **Claude Desktop** card. The card is there once Corveil
accepts Claude Desktop sign-in for your organization. The download has
the `.mobileconfig`, `.reg` and `.json` files below, filled in for your
organization:

- `organization_id` in the sign-in URL is your organization, so
  **Sign in to your organization** goes straight to your identity
  provider, with no email page first. It goes through your
  organization's single sign-on connection, so set that up first.
- `inferenceGatewayBaseUrl` is your Corveil origin.
- `deploymentDisplayName` is your organization's name, and the sample
  banner is left out.

If your organization has no SSO connection in Corveil, the
`organization_id` URL can't sign anyone in. Set `authorizationUrl` to
`https://api.workos.com/user_management/authorize?provider=authkit`
instead, and people sign in through AuthKit's email page.

A comment beside the placeholder in the `.mobileconfig`, `.reg` and
Intune files says what it is. JSON has no comments, so
`managed-settings.json` and `corveil.json` carry only the placeholder.

Start sign-in from Claude Desktop, not from your identity provider's
app tile. A sign-in started from the tile has no Desktop request to
return to, so it ends in the Corveil dashboard. Desktop opens the
device's default browser, so be signed in to your identity provider in
that browser.

## The claude.ai sign-in is hidden

Every template sets `disableDeploymentModeChooser` to true: `<true/>`
in the `.mobileconfig`s, `true` in the JSON files, and a `DWORD` of 1 in
the `.reg` files and the Intune scripts. Claude Desktop then offers only
the Corveil sign-in, with no switch to a claude.ai sign-in. In a managed
profile, the key also keeps the profile in charge. Without it, a user
can sign in to a claude.ai organization that configures Claude Desktop
in Anthropic's Admin Console, and the device then follows that
organization's configuration. Claude Desktop has read the key since
1.3834.0, earlier than either profile's minimum release. See Anthropic's
[configuration reference](https://claude.com/docs/third-party/claude-desktop/configuration#disabledeploymentmodechooser)
and [Restrict a device to one deployment mode](https://claude.com/docs/third-party/claude-desktop/mdm#restrict-a-device-to-one-deployment-mode).

Remove the key if people on these devices also need to sign in to
claude.ai. Corveil's download doesn't set it yet; it will once
corveil/corveil#5376 ships. Until then, add it to the downloaded files
yourself.

The templates don't set `deploymentMode`, which replaces this key from
Claude Desktop 4.16336.0. Earlier releases don't read it, and on Linux
they treat a key they don't recognize in `managed-settings.json` as an
error. Don't add it to `managed-settings.json` until every Linux device
is on 4.16336.0 or later.

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
`chatTabEnabled`, `endUserAttribution` and
`disableDeploymentModeChooser` are `DWORD` values.

`deploymentDisplayName`, `deploymentDisplaySubtitle`, and the banner text
are sample labels. Replace them before you deploy, or use your
organization's download.

## 2.7032 profile

| File | Where it goes |
| --- | --- |
| `corveil-2.7032.mobileconfig` | macOS MDM, user scope. Payload domain `com.anthropic.claudefordesktop`. |
| `corveil-2.7032.reg` | Windows. Values directly under `HKLM\SOFTWARE\Policies\Claude`. |

Sign-in sets `inferenceCredentialKind` to `external-idp` and supplies
`inferenceIdpOidc`, with `inferenceIdpAuthFlow` set to `browser`.
`inferenceIdpOidc` is one JSON string in both files.

These files set only the gateway and sign-in keys and
`disableDeploymentModeChooser`, a `DWORD` in the `.reg`. They leave the
chat tab, the deployment labels, end-user attribution, and the banner at
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

Get your organization's values from Corveil: on **People & Access →
Organization**, choose **Get Desktop profile** on the **Claude
Desktop** card. Today the download has the `.reg` files but not these
scripts. Once corveil/corveil#5376 ships, it will also include
ready-made `install.ps1`, `detect.ps1` and `uninstall.ps1` with your
organization's sign-in URL filled in, which you can upload unchanged.

Until then, use the scripts here. **Before you upload them, replace
`YOUR_ORGANIZATION_ID` in both `install.ps1` and `detect.ps1`** with
the `organization_id` value from the `authorizationUrl` in your
organization's `corveil-2.7032.reg`. A device that runs `install.ps1`
with the placeholder still in it can't sign in.

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
