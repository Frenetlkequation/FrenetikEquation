<#
.SYNOPSIS
Reports on DFS namespaces.

.DESCRIPTION
This script inventories Distributed File System namespaces for file services documentation and review.

.EXAMPLE
.\Get-DFSNamespaceReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

#Requires -Module DFSN

Write-Host "Retrieving DFS namespaces..." -ForegroundColor Cyan

$report = Get-DfsnRoot -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Path         = $_.Path
        State        = $_.State
        Type         = $_.Type
        Description  = $_.Description
    }
}

if ($report.Count -eq 0) {
    Write-Host "No DFS namespaces found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) DFS namespace record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
