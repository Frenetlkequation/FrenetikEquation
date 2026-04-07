# Entra ID Scripts

This folder contains scripts related to Entra ID administration, reporting, and operational support.

## Available Scripts

### Export-EntraUsers.ps1
Exports Entra ID user information for reporting and audit purposes.

### Get-EntraGroupMembersReport.ps1
Retrieves and reports group membership information for Entra ID groups.

### Get-EntraSignInReport.ps1
Exports Entra ID sign-in activity logs for security monitoring and compliance auditing.

### Get-EntraGuestUsersReport.ps1
Identifies guest (external) user accounts in Entra ID with sign-in activity and acceptance status.

### Get-EntraAppCredentialReport.ps1
Reports on application registrations with expiring or expired client secrets and certificates.

### Get-EntraConditionalAccessReport.ps1
Retrieves Conditional Access policies with state, conditions, and grant controls for security review.

### Get-EntraDirectoryRolesReport.ps1
Reports on Entra ID directory role assignments and their members for privileged access review.

### Get-EntraServicePrincipalReport.ps1
Retrieves service principals with their API permissions and app role assignments for security auditing.

### Get-EntraAppOwnersReport.ps1
Reports on application registrations and their assigned owners to help identify apps without accountable ownership.

### Get-EntraConnectVersionReport.ps1
Reports on Microsoft Entra Connect installed version and flags servers that are not on the latest published release.

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
