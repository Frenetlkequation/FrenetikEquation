<#
.SYNOPSIS
Reports on cluster quorum configuration.

.DESCRIPTION
This script retrieves failover cluster quorum information for operational review.

.EXAMPLE
.\Get-ClusterQuorumReport.ps1

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

Write-Host "Retrieving cluster quorum settings..." -ForegroundColor Cyan

$quorum = Get-ClusterQuorum -ErrorAction SilentlyContinue

$report = if ($quorum) {
    [PSCustomObject]@{
        QuorumType   = $quorum.QuorumType
        ResourceName = $quorum.ResourceName
        WitnessType  = $quorum.WitnessType
        State        = $quorum.State
    }
} else {
    @()
}

if ($report.Count -eq 0) {
    Write-Host "No cluster quorum data found." -ForegroundColor Yellow
}
else {
    Write-Host "Cluster quorum settings retrieved." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
