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

### Get-CertificateExpiryReport.ps1
Checks SSL/TLS certificates on remote endpoints for validity and expiration to support proactive certificate management.

### Get-EventLogReport.ps1
Queries System and Application event logs for errors and warnings on local or remote servers.

### Get-DNSConfigurationReport.ps1
Retrieves DNS client configuration and tests DNS resolution for network troubleshooting and documentation.

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
