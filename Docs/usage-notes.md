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

All scripts should be reviewed, tested, and validated in a non-production environment before use in production systems.
