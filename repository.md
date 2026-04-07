# FrenetikEquation PowerShell Script Repository

FrenetikEquation PowerShell Script Repository is a practical collection of PowerShell scripts for Active Directory, Entra ID, Azure, Microsoft 365, and Windows infrastructure administration. The repository is built for reporting, auditing, operational support, governance reviews, tenant visibility, server health checks, and day-to-day IT administration.

This repository currently includes 168 PowerShell scripts covering:

- Active Directory audit scripts
- Entra ID reporting and security review scripts
- Azure inventory, governance, and security scripts
- Microsoft 365 administration and reporting scripts
- Windows infrastructure and server operations scripts

## Active Directory Scripts

These Active Directory PowerShell scripts focus on user auditing, group membership reporting, computer inventory, password health, GPO reporting, OU structure analysis, domain controller health checks, lockout monitoring, and privileged access review.

- `ActiveDirectory/Audit-InactiveUsers.ps1`: I.
- `ActiveDirectory/Export-ADGroupMembership.ps1`: E.
- `ActiveDirectory/Export-ADUserReport.ps1`: E.
- `ActiveDirectory/Get-ADAccountExpirationReport.ps1`: R.
- `ActiveDirectory/Get-ADComputerReport.ps1`: R.
- `ActiveDirectory/Get-ADDisabledAccountsReport.ps1`: R.
- `ActiveDirectory/Get-ADDomainControllerHealthReport.ps1`: R.
- `ActiveDirectory/Get-ADDomainTrustReport.ps1`: R.
- `ActiveDirectory/Get-ADDuplicateSPNReport.ps1`: R.
- `ActiveDirectory/Get-ADFineGrainedPasswordPolicyReport.ps1`: R.
- `ActiveDirectory/Get-ADGPOReport.ps1`: R.
- `ActiveDirectory/Get-ADGroupScopeReport.ps1`: R.
- `ActiveDirectory/Get-ADGroupWithoutMembersReport.ps1`: R.
- `ActiveDirectory/Get-ADInactiveComputersByOUReport.ps1`: R.
- `ActiveDirectory/Get-ADKerberosDelegationReport.ps1`: R.
- `ActiveDirectory/Get-ADNestedGroupMembershipReport.ps1`: R.
- `ActiveDirectory/Get-ADOUDelegationReport.ps1`: R.
- `ActiveDirectory/Get-ADOUStructureReport.ps1`: R.
- `ActiveDirectory/Get-ADPasswordStatusReport.ps1`: R.
- `ActiveDirectory/Get-ADPrivilegedGroupChangeAuditReport.ps1`: R.
- `ActiveDirectory/Get-ADPrivilegedGroupMembersReport.ps1`: R.
- `ActiveDirectory/Get-ADPrivilegedUsersReport.ps1`: R.
- `ActiveDirectory/Get-ADRecentlyCreatedComputersReport.ps1`: R.
- `ActiveDirectory/Get-ADRecentlyCreatedUsersReport.ps1`: R.
- `ActiveDirectory/Get-ADReplicationPartnerReport.ps1`: R.
- `ActiveDirectory/Get-ADServiceAccountReport.ps1`: R.
- `ActiveDirectory/Get-ADSIDHistoryReport.ps1`: R.
- `ActiveDirectory/Get-ADStaleComputerReport.ps1`: R.
- `ActiveDirectory/Get-ADUnconstrainedDelegationReport.ps1`: R.
- `ActiveDirectory/Get-ADUserDepartmentMismatchReport.ps1`: R.
- `ActiveDirectory/Get-ADUserLastLogonTrendReport.ps1`: R.
- `ActiveDirectory/Get-ADUserLockoutReport.ps1`: R.
- `ActiveDirectory/Get-ADUserPasswordExpiryForecastReport.ps1`: R.

## Entra ID Scripts

These Entra ID PowerShell scripts help with tenant reporting, sign-in monitoring, guest user reviews, application credential tracking, Conditional Access visibility, role review, Microsoft Entra Connect version checking, MFA readiness, consent auditing, and service principal governance.

- `EntraID/Export-EntraUsers.ps1`: E.
- `EntraID/Get-EntraAdminConsentAppsReport.ps1`: R.
- `EntraID/Get-EntraAppCredentialReport.ps1`: R.
- `EntraID/Get-EntraAppOwnersReport.ps1`: R.
- `EntraID/Get-EntraAuthMethodsPolicyReport.ps1`: R.
- `EntraID/Get-EntraB2BInvitationsReport.ps1`: R.
- `EntraID/Get-EntraConditionalAccessCoverageReport.ps1`: R.
- `EntraID/Get-EntraConditionalAccessReport.ps1`: R.
- `EntraID/Get-EntraConnectVersionReport.ps1`: R.
- `EntraID/Get-EntraDeviceComplianceSummaryReport.ps1`: R.
- `EntraID/Get-EntraDirectoryAuditReport.ps1`: R.
- `EntraID/Get-EntraDirectoryQuotaReport.ps1`: R.
- `EntraID/Get-EntraDirectoryRolesReport.ps1`: R.
- `EntraID/Get-EntraDynamicGroupRulesReport.ps1`: R.
- `EntraID/Get-EntraEnterpriseAppAssignmentsReport.ps1`: R.
- `EntraID/Get-EntraExternalIdentitiesPolicyReport.ps1`: R.
- `EntraID/Get-EntraGroupLifecycleReport.ps1`: R.
- `EntraID/Get-EntraGroupMembersReport.ps1`: R.
- `EntraID/Get-EntraGuestUsersReport.ps1`: R.
- `EntraID/Get-EntraIdentityProtectionPolicyReport.ps1`: R.
- `EntraID/Get-EntraInactiveUsersReport.ps1`: R.
- `EntraID/Get-EntraMFARegistrationReport.ps1`: R.
- `EntraID/Get-EntraNamedLocationsReport.ps1`: R.
- `EntraID/Get-EntraOauthPermissionGrantsReport.ps1`: R.
- `EntraID/Get-EntraPIMRoleEligibilityReport.ps1`: R.
- `EntraID/Get-EntraPrivilegedRoleAssignmentsReport.ps1`: R.
- `EntraID/Get-EntraRiskDetectionsReport.ps1`: R.
- `EntraID/Get-EntraRiskyUsersReport.ps1`: R.
- `EntraID/Get-EntraSecurityDefaultsReport.ps1`: R.
- `EntraID/Get-EntraServicePrincipalReport.ps1`: R.
- `EntraID/Get-EntraSignInReport.ps1`: E.
- `EntraID/Get-EntraStaleAppCredentialsReport.ps1`: R.
- `EntraID/Get-EntraTenantSettingsReport.ps1`: R.
- `EntraID/Get-EntraUserLicenseReport.ps1`: R.

## Azure Scripts

These Azure PowerShell scripts are designed for subscription inventory, RBAC review, tag compliance, network security review, virtual machine reporting, storage security checks, Key Vault expiry monitoring, SQL reporting, public IP visibility, App Service governance, policy compliance, advisor optimization, and load balancer visibility.

- `Azure/Export-AzureRoleAssignments.ps1`: E.
- `Azure/Get-AzureAdvisorRecommendationsReport.ps1`: R.
- `Azure/Get-AzureAKSClusterReport.ps1`: R.
- `Azure/Get-AzureApplicationGatewayReport.ps1`: R.
- `Azure/Get-AzureAppServicePlanReport.ps1`: R.
- `Azure/Get-AzureAppServiceReport.ps1`: R.
- `Azure/Get-AzureAutomationAccountReport.ps1`: R.
- `Azure/Get-AzureBackupVaultReport.ps1`: R.
- `Azure/Get-AzureBastionHostReport.ps1`: R.
- `Azure/Get-AzureContainerRegistryReport.ps1`: R.
- `Azure/Get-AzureCosmosDBReport.ps1`: R.
- `Azure/Get-AzureCostByResourceGroupReport.ps1`: R.
- `Azure/Get-AzureDDoSPlanReport.ps1`: R.
- `Azure/Get-AzureFirewallReport.ps1`: R.
- `Azure/Get-AzureFunctionAppReport.ps1`: R.
- `Azure/Get-AzureKeyVaultExpiryReport.ps1`: R.
- `Azure/Get-AzureLoadBalancerReport.ps1`: R.
- `Azure/Get-AzureLogicAppReport.ps1`: R.
- `Azure/Get-AzureManagedDiskReport.ps1`: R.
- `Azure/Get-AzureMonitorAlertRuleReport.ps1`: R.
- `Azure/Get-AzureNSGRulesReport.ps1`: R.
- `Azure/Get-AzurePolicyComplianceReport.ps1`: R.
- `Azure/Get-AzurePrivateEndpointReport.ps1`: R.
- `Azure/Get-AzurePublicIPReport.ps1`: R.
- `Azure/Get-AzureRecoveryServicesReport.ps1`: R.
- `Azure/Get-AzureRedisCacheReport.ps1`: R.
- `Azure/Get-AzureResourcesReport.ps1`: R.
- `Azure/Get-AzureRouteTableReport.ps1`: R.
- `Azure/Get-AzureSQLDatabaseReport.ps1`: R.
- `Azure/Get-AzureStorageAccountReport.ps1`: R.
- `Azure/Get-AzureSubnetDelegationReport.ps1`: R.
- `Azure/Get-AzureTagComplianceReport.ps1`: R.
- `Azure/Get-AzureVirtualNetworkReport.ps1`: R.
- `Azure/Get-AzureVMStatusReport.ps1`: R.

## Microsoft 365 Scripts

These Microsoft 365 PowerShell scripts support license reporting, Exchange Online administration, mailbox auditing, Teams reporting, MFA review, OneDrive and SharePoint usage analysis, mail flow governance, forwarding review, permission auditing, and service health tracking.

- `Microsoft365/Export-M365Licenses.ps1`: E.
- `Microsoft365/Export-TeamsReport.ps1`: E.
- `Microsoft365/Get-DistributionGroupReport.ps1`: R.
- `Microsoft365/Get-ExchangeAcceptedDomainReport.ps1`: R.
- `Microsoft365/Get-ExchangeConnectorReport.ps1`: R.
- `Microsoft365/Get-ExchangeMobileDeviceAccessReport.ps1`: R.
- `Microsoft365/Get-M365AntiPhishPolicyReport.ps1`: R.
- `Microsoft365/Get-M365AppUsageReport.ps1`: R.
- `Microsoft365/Get-M365DLPPolicyReport.ps1`: R.
- `Microsoft365/Get-M365GuestAccessSettingsReport.ps1`: R.
- `Microsoft365/Get-M365InactiveMailboxReport.ps1`: R.
- `Microsoft365/Get-M365LicenseUtilizationSummaryReport.ps1`: R.
- `Microsoft365/Get-M365MailboxArchiveStatusReport.ps1`: R.
- `Microsoft365/Get-M365MailboxSizeSummaryReport.ps1`: R.
- `Microsoft365/Get-M365MFAStatusReport.ps1`: R.
- `Microsoft365/Get-M365RetentionPolicyReport.ps1`: R.
- `Microsoft365/Get-M365RoleAssignmentReport.ps1`: R.
- `Microsoft365/Get-M365ServiceHealthReport.ps1`: R.
- `Microsoft365/Get-M365UnifiedGroupReport.ps1`: R.
- `Microsoft365/Get-M365UserSignInSummaryReport.ps1`: R.
- `Microsoft365/Get-MailboxAuditStatusReport.ps1`: R.
- `Microsoft365/Get-MailboxForwardingReport.ps1`: R.
- `Microsoft365/Get-MailboxPermissionReport.ps1`: R.
- `Microsoft365/Get-MailboxReport.ps1`: R.
- `Microsoft365/Get-MailFlowRulesReport.ps1`: R.
- `Microsoft365/Get-OneDriveSharingLinksReport.ps1`: R.
- `Microsoft365/Get-OneDriveUsageReport.ps1`: R.
- `Microsoft365/Get-SharedMailboxReport.ps1`: R.
- `Microsoft365/Get-SharePointExternalSharingReport.ps1`: R.
- `Microsoft365/Get-SharePointSiteCollectionAdminReport.ps1`: R.
- `Microsoft365/Get-SharePointSiteUsageReport.ps1`: R.
- `Microsoft365/Get-TeamsChannelInventoryReport.ps1`: R.
- `Microsoft365/Get-TeamsPolicyAssignmentReport.ps1`: R.
- `Microsoft365/Get-TeamsUserActivityReport.ps1`: R.

## Infrastructure Scripts

These Windows infrastructure PowerShell scripts focus on server inventory, network connectivity testing, disk space checks, service health, pending updates, certificate expiry, event log review, DNS troubleshooting, uptime and reboot status, local administrator review, local account hygiene, and installed software inventory.

- `Infrastructure/Get-BitLockerStatusReport.ps1`: R.
- `Infrastructure/Get-CertificateExpiryReport.ps1`: R.
- `Infrastructure/Get-CPUUtilizationReport.ps1`: R.
- `Infrastructure/Get-DiskSpaceReport.ps1`: C.
- `Infrastructure/Get-DNSConfigurationReport.ps1`: R.
- `Infrastructure/Get-EventLogReport.ps1`: R.
- `Infrastructure/Get-FirewallProfileReport.ps1`: R.
- `Infrastructure/Get-InstalledHotfixReport.ps1`: R.
- `Infrastructure/Get-InstalledSoftwareReport.ps1`: R.
- `Infrastructure/Get-LocalAdministratorsReport.ps1`: R.
- `Infrastructure/Get-LocalGroupMembershipReport.ps1`: R.
- `Infrastructure/Get-LocalUserAccountReport.ps1`: R.
- `Infrastructure/Get-MemoryUsageReport.ps1`: R.
- `Infrastructure/Get-NetworkAdapterReport.ps1`: R.
- `Infrastructure/Get-NTPConfigurationReport.ps1`: R.
- `Infrastructure/Get-OSVersionReport.ps1`: R.
- `Infrastructure/Get-PageFileConfigurationReport.ps1`: R.
- `Infrastructure/Get-PendingUpdatesReport.ps1`: R.
- `Infrastructure/Get-PerformanceCounterSnapshotReport.ps1`: R.
- `Infrastructure/Get-PrinterInventoryReport.ps1`: R.
- `Infrastructure/Get-RDPSessionReport.ps1`: R.
- `Infrastructure/Get-RebootPendingStatusReport.ps1`: R.
- `Infrastructure/Get-ScheduledTaskStatusReport.ps1`: R.
- `Infrastructure/Get-ServerInventory.ps1`: C.
- `Infrastructure/Get-SMBSharesReport.ps1`: R.
- `Infrastructure/Get-StartupProgramReport.ps1`: R.
- `Infrastructure/Get-SystemUptimeAndRebootReport.ps1`: R.
- `Infrastructure/Get-TimeSyncStatusReport.ps1`: R.
- `Infrastructure/Get-TopProcessReport.ps1`: R.
- `Infrastructure/Get-UptimeReport.ps1`: R.
- `Infrastructure/Get-WindowsServicesReport.ps1`: R.
- `Infrastructure/Get-WinRMConfigurationReport.ps1`: R.
- `Infrastructure/Test-NetworkConnectivityReport.ps1`: T.

## Repository Summary

This PowerShell repository is intended for system administrators, infrastructure engineers, cloud engineers, security teams, Microsoft 365 administrators, and IT consultants who need ready-to-use scripts for Microsoft environments. The script library covers Active Directory reporting, Entra ID auditing, Azure governance, Microsoft 365 administration, and Windows infrastructure operations in a single repository.

All scripts should be reviewed, tested, and validated in a non-production environment before use in production systems.

