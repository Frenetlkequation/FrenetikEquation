# Microsoft 365 Scripts

This folder contains scripts related to Microsoft 365 administration, reporting, and operational support.

## Available Scripts

### Export-M365Licenses.ps1
Exports Microsoft 365 license assignment information for reporting and cost management.

### Get-MailboxReport.ps1
Retrieves and reports mailbox information for Exchange Online administration and auditing.

### Get-SharedMailboxReport.ps1
Reports on shared mailboxes including size, delegate permissions, and forwarding status.

### Get-M365MFAStatusReport.ps1
Checks MFA registration status for all users, identifying accounts without MFA for security compliance.

### Export-TeamsReport.ps1
Retrieves Microsoft Teams information including owners, member counts, and channels for governance reporting.

### Get-DistributionGroupReport.ps1
Reports on Exchange Online distribution groups including membership, ownership, and empty group identification.

### Get-OneDriveUsageReport.ps1
Retrieves OneDrive for Business storage usage per user for capacity planning and governance.

### Get-MailFlowRulesReport.ps1
Reports on Exchange Online mail transport rules for governance and security review.

### Get-MailboxForwardingReport.ps1
Reports on mailbox forwarding configuration in Exchange Online for security review and mail flow auditing.

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
