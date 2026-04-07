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

Disclaimer:
Test this script in a non-production environment before using it in production.
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
