<#
.SYNOPSIS
Reports on DNS configuration for local or remote servers.

.DESCRIPTION
This script retrieves DNS client configuration and tests DNS resolution
on specified servers. Useful for network troubleshooting and infrastructure
documentation.

.PARAMETER ComputerName
One or more computer names to query. Default is the local computer.

.PARAMETER TestDomains
Domains to test for DNS resolution. Default includes common Microsoft domains.

.EXAMPLE
.\Get-DNSConfigurationReport.ps1 -ComputerName "Server01", "Server02"

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied,
    including but not limited to the warranties of merchantability, fitness for a
    particular purpose, and noninfringement.

    In no event shall the authors, contributors, or copyright holders (FrenetikEquation)
    be liable for any claim, damages, or other liability, whether in an action of
    contract, tort, or otherwise, arising from, out of, or in connection with this
    script or the use or other dealings in this script. This includes, without
    limitation, any direct, indirect, incidental, special, exemplary, or consequential
    damages, including but not limited to loss of data, loss of revenue, business
    interruption, or damage to systems.

    USE AT YOUR OWN RISK. You are solely responsible for testing this script in a
    non-production environment before deploying to any production system. The user
    assumes all responsibility and risk for the use of this script. It is strongly
    recommended that you review, understand, and validate the script logic before
    execution.

    By using this script, you acknowledge and agree to these terms. If you do not
    agree, do not use this script. Refer to the LICENSE file in the root of this
    repository for the full license terms.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string[]]$ComputerName = $env:COMPUTERNAME,

    [Parameter()]
    [string[]]$TestDomains = @(
        "login.microsoftonline.com"
        "graph.microsoft.com"
        "google.com"
    )
)

Write-Host "Retrieving DNS configuration..." -ForegroundColor Cyan

$configReport = foreach ($computer in $ComputerName) {
    try {
        $adapters = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -ComputerName $computer -Filter "IPEnabled=True" -ErrorAction Stop

        foreach ($adapter in $adapters) {
            [PSCustomObject]@{
                ComputerName   = $computer
                AdapterName    = $adapter.Description
                IPAddress      = ($adapter.IPAddress -join ", ")
                DNSServers     = ($adapter.DNSServerSearchOrder -join ", ")
                DNSSuffix      = $adapter.DNSDomainSuffixSearchOrder -join ", "
                DHCPEnabled    = $adapter.DHCPEnabled
                DNSDomain      = $adapter.DNSDomain
            }
        }
    }
    catch {
        Write-Warning "Failed to query DNS config on $computer : $_"
    }
}

Write-Host "`n--- DNS Configuration ---" -ForegroundColor Yellow
if ($configReport.Count -gt 0) {
    $configReport | Format-Table -AutoSize
}

Write-Host "`n--- DNS Resolution Tests ---" -ForegroundColor Yellow

$resolutionReport = foreach ($domain in $TestDomains) {
    try {
        $result = Resolve-DnsName -Name $domain -ErrorAction Stop | Select-Object -First 1

        [PSCustomObject]@{
            Domain      = $domain
            RecordType  = $result.Type
            IPAddress   = $result.IPAddress
            TTL         = $result.TTL
            Status      = "Resolved"
        }
    }
    catch {
        [PSCustomObject]@{
            Domain      = $domain
            RecordType  = "N/A"
            IPAddress   = "N/A"
            TTL         = "N/A"
            Status      = "Failed"
        }
    }
}

$failed = ($resolutionReport | Where-Object { $_.Status -eq "Failed" }).Count
Write-Host "Tested $($resolutionReport.Count) domain(s). Failed: $failed" -ForegroundColor Green
$resolutionReport | Format-Table -AutoSize
