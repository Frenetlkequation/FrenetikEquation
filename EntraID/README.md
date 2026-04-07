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

## Usage Notes

Review script parameters and permissions before use.
Always test in a non-production environment first.
