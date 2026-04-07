# FrenetikEquation PowerShell Script Repository

FrenetikEquation PowerShell Script Repository is a practical collection of PowerShell scripts for Active Directory, Entra ID, Azure, Microsoft 365, and Windows infrastructure administration. The repository is built for reporting, auditing, operational support, governance reviews, tenant visibility, server health checks, and day-to-day IT administration.

This repository currently includes 48 PowerShell scripts covering:

- Active Directory audit scripts
- Entra ID reporting and security review scripts
- Azure inventory, governance, and security scripts
- Microsoft 365 administration and reporting scripts
- Windows infrastructure and server operations scripts

## Active Directory Scripts

These Active Directory PowerShell scripts focus on user auditing, group membership reporting, computer inventory, password health, GPO reporting, OU structure analysis, and privileged access review.

- `ActiveDirectory/Audit-InactiveUsers.ps1`: Identifies inactive user accounts in Active Directory based on last logon date for security auditing and cleanup purposes.
- `ActiveDirectory/Export-ADUserReport.ps1`: Exports Active Directory user information for reporting, auditing, and administrative review.
- `ActiveDirectory/Export-ADGroupMembership.ps1`: Exports group membership information from Active Directory for auditing and documentation.
- `ActiveDirectory/Get-ADPasswordStatusReport.ps1`: Reports on password status for AD users including expiration dates, accounts with passwords set to never expire, and locked-out accounts.
- `ActiveDirectory/Get-ADDisabledAccountsReport.ps1`: Identifies disabled computer and user accounts in Active Directory for cleanup planning and security auditing.
- `ActiveDirectory/Get-ADOUStructureReport.ps1`: Reports on Active Directory Organizational Unit structure including user, computer, and group counts per OU.
- `ActiveDirectory/Get-ADComputerReport.ps1`: Retrieves computer accounts from Active Directory with OS, last logon, and inactive status for inventory and security auditing.
- `ActiveDirectory/Get-ADGPOReport.ps1`: Reports on Group Policy Objects including link status, enforcement, modification dates, and identifies unlinked GPOs.
- `ActiveDirectory/Get-ADPrivilegedGroupMembersReport.ps1`: Reports on privileged Active Directory group memberships to support privileged access reviews and security auditing.

## Entra ID Scripts

These Entra ID PowerShell scripts help with tenant reporting, sign-in monitoring, guest user reviews, application credential tracking, Conditional Access visibility, role review, Microsoft Entra Connect version checking, and service principal auditing.

- `EntraID/Export-EntraUsers.ps1`: Exports Entra ID user information for reporting and audit purposes.
- `EntraID/Get-EntraGroupMembersReport.ps1`: Retrieves and reports group membership information for Entra ID groups.
- `EntraID/Get-EntraSignInReport.ps1`: Exports Entra ID sign-in activity logs for security monitoring and compliance auditing.
- `EntraID/Get-EntraGuestUsersReport.ps1`: Identifies guest external user accounts in Entra ID with sign-in activity and acceptance status.
- `EntraID/Get-EntraAppCredentialReport.ps1`: Reports on application registrations with expiring or expired client secrets and certificates.
- `EntraID/Get-EntraConditionalAccessReport.ps1`: Retrieves Conditional Access policies with state, conditions, and grant controls for security review.
- `EntraID/Get-EntraDirectoryRolesReport.ps1`: Reports on Entra ID directory role assignments and their members for privileged access review.
- `EntraID/Get-EntraServicePrincipalReport.ps1`: Retrieves service principals with their API permissions and app role assignments for security auditing.
- `EntraID/Get-EntraAppOwnersReport.ps1`: Reports on application registrations and their assigned owners to help identify apps without accountable ownership.
- `EntraID/Get-EntraConnectVersionReport.ps1`: Reports on Microsoft Entra Connect installed version and flags servers that are not on the latest published release.

## Azure Scripts

These Azure PowerShell scripts are designed for subscription inventory, RBAC review, tag compliance, network security review, virtual machine reporting, storage security checks, Key Vault expiry monitoring, SQL reporting, public IP visibility, and App Service governance.

- `Azure/Get-AzureResourcesReport.ps1`: Retrieves and reports on Azure resources across subscriptions for inventory and auditing purposes.
- `Azure/Export-AzureRoleAssignments.ps1`: Exports Azure role assignment information for RBAC review and security auditing.
- `Azure/Get-AzureTagComplianceReport.ps1`: Audits resource groups for required tags to support governance and cost management compliance.
- `Azure/Get-AzureNSGRulesReport.ps1`: Reports on Network Security Group rules, highlighting open inbound rules for security review.
- `Azure/Get-AzureVMStatusReport.ps1`: Retrieves Azure VM inventory including power state, sizing, and OS information.
- `Azure/Get-AzureStorageAccountReport.ps1`: Audits Azure storage accounts across subscriptions for configuration, security settings, and public access exposure.
- `Azure/Get-AzureKeyVaultExpiryReport.ps1`: Checks Azure Key Vault secrets and certificates for expiration to prevent service outages from credential expiry.
- `Azure/Get-AzureSQLDatabaseReport.ps1`: Reports on Azure SQL servers and databases including tier, sizing, and firewall rule security review.
- `Azure/Get-AzurePublicIPReport.ps1`: Retrieves Azure public IP addresses across subscriptions including allocation method, address assignment, and associated resources.
- `Azure/Get-AzureAppServiceReport.ps1`: Reports on Azure App Service applications including state, HTTPS enforcement, managed identity usage, and hosting plan details.

## Microsoft 365 Scripts

These Microsoft 365 PowerShell scripts support license reporting, Exchange Online administration, mailbox auditing, Teams reporting, MFA review, OneDrive usage analysis, mail flow governance, mailbox forwarding review, and mailbox permission auditing.

- `Microsoft365/Export-M365Licenses.ps1`: Exports Microsoft 365 license assignment information for reporting and cost management.
- `Microsoft365/Get-MailboxReport.ps1`: Retrieves and reports mailbox information for Exchange Online administration and auditing.
- `Microsoft365/Get-SharedMailboxReport.ps1`: Reports on shared mailboxes including size, delegate permissions, and forwarding status.
- `Microsoft365/Get-M365MFAStatusReport.ps1`: Checks MFA registration status for all users, identifying accounts without MFA for security compliance.
- `Microsoft365/Export-TeamsReport.ps1`: Retrieves Microsoft Teams information including owners, member counts, and channels for governance reporting.
- `Microsoft365/Get-DistributionGroupReport.ps1`: Reports on Exchange Online distribution groups including membership, ownership, and empty group identification.
- `Microsoft365/Get-OneDriveUsageReport.ps1`: Retrieves OneDrive for Business storage usage per user for capacity planning and governance.
- `Microsoft365/Get-MailFlowRulesReport.ps1`: Reports on Exchange Online mail transport rules for governance and security review.
- `Microsoft365/Get-MailboxForwardingReport.ps1`: Reports on mailbox forwarding configuration in Exchange Online for security review and mail flow auditing.
- `Microsoft365/Get-MailboxPermissionReport.ps1`: Reports on mailbox delegation settings in Exchange Online including mailbox permissions, Send As, and Send on Behalf access.

## Infrastructure Scripts

These Windows infrastructure PowerShell scripts focus on server inventory, network connectivity testing, disk space checks, service health, pending updates, certificate expiry, event log review, DNS troubleshooting, and uptime reporting.

- `Infrastructure/Get-ServerInventory.ps1`: Collects server inventory information including OS, hardware, and network details for documentation and auditing.
- `Infrastructure/Test-NetworkConnectivityReport.ps1`: Tests network connectivity to specified endpoints and produces a connectivity status report.
- `Infrastructure/Get-DiskSpaceReport.ps1`: Monitors disk space usage and flags volumes below a free space threshold for capacity management.
- `Infrastructure/Get-WindowsServicesReport.ps1`: Reports on Windows services status, identifying stopped automatic services that may need attention.
- `Infrastructure/Get-PendingUpdatesReport.ps1`: Queries pending Windows updates for patch management and compliance auditing.
- `Infrastructure/Get-CertificateExpiryReport.ps1`: Checks SSL/TLS certificates on remote endpoints for validity and expiration to support proactive certificate management.
- `Infrastructure/Get-EventLogReport.ps1`: Queries System and Application event logs for errors and warnings on local or remote servers.
- `Infrastructure/Get-DNSConfigurationReport.ps1`: Retrieves DNS client configuration and tests DNS resolution for network troubleshooting and documentation.
- `Infrastructure/Get-UptimeReport.ps1`: Reports on server last boot time and uptime duration to support reboot planning and operational health checks.

## Repository Summary

This PowerShell repository is intended for system administrators, infrastructure engineers, cloud engineers, security teams, Microsoft 365 administrators, and IT consultants who need ready-to-use scripts for Microsoft environments. The script library covers Active Directory reporting, Entra ID auditing, Azure governance, Microsoft 365 administration, and Windows infrastructure operations in a single repository.

All scripts should be reviewed, tested, and validated in a non-production environment before use in production systems.
