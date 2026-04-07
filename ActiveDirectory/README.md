# Active Directory Scripts

This folder contains scripts related to Active Directory administration, reporting, and operational support.

## Available Scripts

### Audit-InactiveUsers.ps1
Identifies inactive user accounts in Active Directory based on last logon date for security auditing and cleanup purposes.

### Export-ADUserReport.ps1
Exports Active Directory user information for reporting, auditing, and administrative review.

### Export-ADGroupMembership.ps1
Exports group membership information from Active Directory for auditing and documentation.

### Get-ADPasswordStatusReport.ps1
Reports on password status for AD users including expiration dates, accounts with passwords set to never expire, and locked-out accounts.

### Get-ADDisabledAccountsReport.ps1
Identifies disabled computer and user accounts in Active Directory for cleanup planning and security auditing.

### Get-ADOUStructureReport.ps1
Reports on Active Directory Organizational Unit structure including user, computer, and group counts per OU.

### Get-ADComputerReport.ps1
Retrieves computer accounts from Active Directory with OS, last logon, and inactive status for inventory and security auditing.

### Get-ADGPOReport.ps1
Reports on Group Policy Objects including link status, enforcement, modification dates, and identifies unlinked GPOs.

## Usage Notes

Review script parameters and permissions before use.
Always test in a non-production environment first.

## Legal Disclaimer

The scripts in this folder are provided **"AS IS"** without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement.

**In no event** shall the authors, contributors, or copyright holders (FrenetikEquation) be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with these scripts or the use or other dealings in these scripts. This includes, without limitation, any direct, indirect, incidental, special, exemplary, or consequential damages, including but not limited to:

- Loss of data or corruption of data
- Loss of revenue or profits
- Business interruption
- Damage to systems or infrastructure
- Security incidents resulting from script misuse

**USE AT YOUR OWN RISK.** You are solely responsible for reviewing, understanding, testing, and validating these scripts in a non-production environment before deploying to any production system. The user assumes all responsibility and risk for the use of these scripts.

By using any script in this repository, you acknowledge and agree to these terms. If you do not agree, do not use these scripts. Refer to the [LICENSE](../LICENSE) file in the root of this repository for the full license terms.
