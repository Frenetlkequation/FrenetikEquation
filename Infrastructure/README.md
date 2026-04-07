# Infrastructure Scripts

This folder contains scripts related to infrastructure operations, inventory, and connectivity testing.

## Available Scripts

### Get-ServerInventory.ps1
Collects server inventory information including OS, hardware, and network details for documentation and auditing.

### Test-NetworkConnectivityReport.ps1
Tests network connectivity to specified endpoints and produces a connectivity status report.

### Get-DiskSpaceReport.ps1
Monitors disk space usage and flags volumes below a free space threshold for capacity management.

### Get-WindowsServicesReport.ps1
Reports on Windows services status, identifying stopped automatic services that may need attention.

### Get-PendingUpdatesReport.ps1
Queries pending Windows updates for patch management and compliance auditing.

## Usage Notes

Review script parameters and permissions before use.
Always test in a non-production environment first.
