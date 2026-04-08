<#
.SYNOPSIS
Reports on cluster nodes.

.DESCRIPTION
This script retrieves failover cluster node details for health and inventory review.

.EXAMPLE
.\Get-ClusterNodeReport.ps1

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

Write-Host "Retrieving cluster nodes..." -ForegroundColor Cyan

$report = Get-ClusterNode -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Name         = $_.Name
        State        = $_.State
        NodeWeight   = $_.NodeWeight
        DynamicWeight = $_.DynamicWeight
        DrainStatus  = $_.DrainStatus
    }
}

if ($report.Count -eq 0) {
    Write-Host "No cluster nodes found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) cluster node record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
