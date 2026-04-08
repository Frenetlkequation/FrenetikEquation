<#
.SYNOPSIS
Reports on cluster networks.

.DESCRIPTION
This script retrieves failover cluster network details for administrative review and inventory.

.EXAMPLE
.\Get-ClusterNetworkReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

#Requires -Module FailoverClusters

Write-Host "Retrieving cluster networks..." -ForegroundColor Cyan

$report = Get-ClusterNetwork -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Name      = $_.Name
        Address   = $_.Address
        Role      = $_.Role
        State     = $_.State
        Metric    = $_.Metric
        AutoMetric = $_.AutoMetric
    }
}

if ($report.Count -eq 0) {
    Write-Host "No cluster networks found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) cluster network record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
