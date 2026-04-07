# Usage Notes

## General Requirements

- **PowerShell 5.1 or later** is recommended. PowerShell 7+ is preferred for cross-platform compatibility.
- Scripts that interact with cloud services require the appropriate PowerShell modules to be installed.

## Module Requirements by Category

### Active Directory
- `ActiveDirectory` module (available via RSAT on Windows)

### Entra ID
- `Microsoft.Graph.Users`
- `Microsoft.Graph.Groups`

Install with:
```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

### Azure
- `Az.Accounts`
- `Az.Resources`

Install with:
```powershell
Install-Module Az -Scope CurrentUser
```

### Microsoft 365
- `Microsoft.Graph.Users` (for license reporting)
- `ExchangeOnlineManagement` (for mailbox reporting)

Install with:
```powershell
Install-Module ExchangeOnlineManagement -Scope CurrentUser
```

### Infrastructure
- No additional modules required for most scripts.
- Remote server queries require WinRM or CIM connectivity.

## Permissions

- Scripts require appropriate permissions in the target environment.
- For Microsoft Graph scripts, consent to the required scopes is needed on first run.
- For Azure scripts, an authenticated Azure session is required.

## Disclaimer

All scripts and resources in this repository are provided **"AS IS"** without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement.

**In no event** shall the authors, contributors, or copyright holders (FrenetikEquation) be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with these scripts or the use or other dealings in these scripts. This includes, without limitation, any direct, indirect, incidental, special, exemplary, or consequential damages, including but not limited to loss of data, loss of revenue, business interruption, damage to systems, or security incidents.

**USE AT YOUR OWN RISK.** You are solely responsible for reviewing, understanding, testing, and validating all scripts in a non-production environment before deploying to any production system. The user assumes all responsibility and risk for the use of these scripts.

By using any script in this repository, you acknowledge and agree to these terms. See the [LICENSE](../LICENSE) file for the full license terms.
