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
| `corveil-2.7032.reg` | Windows. Values directly under `HKCU\SOFTWARE\Policies\Claude`. |

Sign-in sets `inferenceCredentialKind` to `external-idp` and supplies
`inferenceIdpOidc`, with `inferenceIdpAuthFlow` set to `browser`.
`inferenceIdpOidc` is one JSON string in both files.

These files set only the gateway and sign-in keys. They leave the chat
tab, the deployment labels, end-user attribution, and the banner at
their defaults. There is no Linux or JSON form of this profile.

Claude Desktop ignores `HKCU\SOFTWARE\Policies\Claude` when any value
is present under `HKLM\SOFTWARE\Policies\Claude`. To move a Windows
device from `corveil.reg` to `corveil-2.7032.reg`, remove the values
under `HKLM\SOFTWARE\Policies\Claude` first.

None of these files contains an API key or a session token.

Setup notes: <https://corveil.com/docs/clients/claude-desktop-mdm>
