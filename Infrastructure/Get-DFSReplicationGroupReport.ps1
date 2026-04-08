<#
.SYNOPSIS
Reports on DFS replication groups.

.DESCRIPTION
This script inventories DFS replication groups for file service topology and health review.

.EXAMPLE
.\Get-DFSReplicationGroupReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

#Requires -Module DFSR

Write-Host "Retrieving DFS replication groups..." -ForegroundColor Cyan

$report = Get-DfsReplicationGroup -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        GroupName    = $_.GroupName
        DomainName   = $_.DomainName
        State        = $_.State
        Description  = $_.Description
    }
}

if ($report.Count -eq 0) {
    Write-Host "No DFS replication groups found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) DFS replication group record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
