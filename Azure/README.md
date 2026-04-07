# Azure Scripts

This folder contains scripts related to Azure administration, reporting, and operational support.

## Available Scripts

### Get-AzureResourcesReport.ps1
Retrieves and reports on Azure resources across subscriptions for inventory and auditing purposes.

### Export-AzureRoleAssignments.ps1
Exports Azure role assignment information for RBAC review and security auditing.

### Get-AzureTagComplianceReport.ps1
Audits resource groups for required tags to support governance and cost management compliance.

### Get-AzureNSGRulesReport.ps1
Reports on Network Security Group rules, highlighting open inbound rules for security review.

### Get-AzureVMStatusReport.ps1
Retrieves Azure VM inventory including power state, sizing, and OS information.

### Get-AzureStorageAccountReport.ps1
Audits Azure storage accounts across subscriptions for configuration, security settings, and public access exposure.

### Get-AzureKeyVaultExpiryReport.ps1
Checks Azure Key Vault secrets and certificates for expiration to prevent service outages from credential expiry.

### Get-AzureSQLDatabaseReport.ps1
Reports on Azure SQL servers and databases including tier, sizing, and firewall rule security review.

### Get-AzurePublicIPReport.ps1
Retrieves Azure public IP addresses across subscriptions including allocation method, address assignment, and associated resources.

### Get-AzureAppServiceReport.ps1
Reports on Azure App Service applications including state, HTTPS enforcement, managed identity usage, and hosting plan details.

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
