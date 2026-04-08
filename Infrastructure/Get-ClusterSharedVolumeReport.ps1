<#
.SYNOPSIS
Reports on cluster shared volumes.

.DESCRIPTION
This script inventories cluster shared volumes for failover cluster storage review.

.EXAMPLE
.\Get-ClusterSharedVolumeReport.ps1

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

Write-Host "Retrieving cluster shared volumes..." -ForegroundColor Cyan

$report = Get-ClusterSharedVolume -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Name         = $_.Name
        State        = $_.State
        OwnerNode    = $_.OwnerNode
        VolumeName   = $_.SharedVolumeInfo.FriendlyVolumeName
        FileSystem   = $_.SharedVolumeInfo.Partition.FileSystem
    }
}

if ($report.Count -eq 0) {
    Write-Host "No cluster shared volumes found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) cluster shared volume record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
