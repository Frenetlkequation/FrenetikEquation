<#
.SYNOPSIS
Reports on Hyper-V checkpoints.

.DESCRIPTION
This script inventories checkpoints for virtual machines on a Hyper-V host.

.EXAMPLE
.\Get-HyperVCheckpointReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

#Requires -Module Hyper-V

Write-Host "Retrieving Hyper-V checkpoints..." -ForegroundColor Cyan

$report = Get-VMCheckpoint -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        VMName      = $_.VMName
        Name        = $_.Name
        SnapshotType = $_.SnapshotType
        CreationTime = $_.CreationTime
        State       = $_.State
    }
}

if ($report.Count -eq 0) {
    Write-Host "No Hyper-V checkpoints found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) Hyper-V checkpoint record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
