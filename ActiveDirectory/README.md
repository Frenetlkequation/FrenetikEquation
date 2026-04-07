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

## Usage Notes

Review script parameters and permissions before use.
Always test in a non-production environment first.
