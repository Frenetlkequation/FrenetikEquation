<#
.SYNOPSIS
Reports on cluster resources.

.DESCRIPTION
This script inventories failover cluster resources for availability and ownership review.

.EXAMPLE
.\Get-ClusterResourceReport.ps1

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

Write-Host "Retrieving cluster resources..." -ForegroundColor Cyan

$report = Get-ClusterResource -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Name        = $_.Name
        State       = $_.State
        OwnerGroup  = $_.OwnerGroup
        OwnerNode   = $_.OwnerNode
        ResourceType = $_.ResourceType
    }
}

if ($report.Count -eq 0) {
    Write-Host "No cluster resources found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) cluster resource record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
