<#
.SYNOPSIS
Reports on Hyper-V replica status.

.DESCRIPTION
This script inventories Hyper-V replication health and status for virtual machines.

.EXAMPLE
.\Get-HyperVReplicaStatusReport.ps1

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

Write-Host "Retrieving Hyper-V replica status..." -ForegroundColor Cyan

$report = Get-VMReplication -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        VMName         = $_.VMName
        ReplicationMode = $_.ReplicationMode
        ReplicationHealth = $_.ReplicationHealth
        State          = $_.State
        PrimaryServer  = $_.PrimaryServer
    }
}

if ($report.Count -eq 0) {
    Write-Host "No Hyper-V replica data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) Hyper-V replica record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
