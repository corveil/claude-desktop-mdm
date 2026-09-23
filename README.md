# Claude Desktop MDM profile for Corveil

Sample managed configuration that points Claude Desktop at the hosted
Corveil gateway and signs the user in through the organization identity
provider. The four files encode the same keys.

| File | Where it goes |
| --- | --- |
| `corveil.mobileconfig` | macOS MDM. Payload domain `com.anthropic.claudefordesktop`. |
| `corveil.reg` | Windows. Values directly under `HKLM\SOFTWARE\Policies\Claude`. |
| `managed-settings.json` | Linux. Install at `/etc/claude-desktop/managed-settings.json`. |
| `corveil.json` | The same profile as JSON. |

`inferenceGatewayOidc` and `banner` are one JSON string in the
`.mobileconfig` and the `.reg`. On Windows, `chatTabEnabled` and
`endUserAttribution` are `DWORD` values.

`deploymentDisplayName`, `deploymentDisplaySubtitle`, and the banner text
are sample labels. Replace them before you deploy. These files contain
no API key and no session token.

Setup notes: <https://corveil.com/docs/clients/claude-desktop-mdm>
