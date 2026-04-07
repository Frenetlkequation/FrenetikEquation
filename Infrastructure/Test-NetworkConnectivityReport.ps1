<#
.SYNOPSIS
Tests network connectivity to specified endpoints.

.DESCRIPTION
This script tests TCP connectivity to a list of endpoints and ports,
producing a connectivity status report for network troubleshooting
and validation.

.PARAMETER Endpoints
An array of hashtables with Host and Port keys defining the targets to test.

.EXAMPLE
.\Test-NetworkConnectivityReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [hashtable[]]$Endpoints = @(
        @{ Host = "google.com";       Port = 443 }
        @{ Host = "login.microsoftonline.com"; Port = 443 }
        @{ Host = "outlook.office365.com";     Port = 443 }
        @{ Host = "graph.microsoft.com";       Port = 443 }
        @{ Host = "8.8.8.8";          Port = 53  }
    )
)

Write-Host "Testing network connectivity..." -ForegroundColor Cyan

$report = foreach ($endpoint in $Endpoints) {
    $hostName = $endpoint.Host
    $port = $endpoint.Port

    try {
        $result = Test-NetConnection -ComputerName $hostName -Port $port -WarningAction SilentlyContinue -ErrorAction Stop

        [PSCustomObject]@{
            Host          = $hostName
            Port          = $port
            TcpSucceeded  = $result.TcpTestSucceeded
            RemoteAddress = $result.RemoteAddress
            Latency       = $result.PingReplyDetails.RoundtripTime
        }
    }
    catch {
        [PSCustomObject]@{
            Host          = $hostName
            Port          = $port
            TcpSucceeded  = $false
            RemoteAddress = "N/A"
            Latency       = "N/A"
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No connectivity tests performed." -ForegroundColor Yellow
}
else {
    Write-Host "Tested $($report.Count) endpoint(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
