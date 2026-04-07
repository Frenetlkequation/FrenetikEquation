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

## Usage Notes

Review script parameters and permissions before use.
Always test in a non-production environment first.
