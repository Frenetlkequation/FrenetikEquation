<#
.SYNOPSIS
Reports on Work Folders sync shares.

.DESCRIPTION
This script inventories Work Folders sync shares for file services review.

.EXAMPLE
.\Get-WorkFolderSyncShareReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving Work Folders sync shares..." -ForegroundColor Cyan

$report = Get-SmbShare -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'work|sync' } | ForEach-Object {
    [PSCustomObject]@{
        Name        = $_.Name
        Path        = $_.Path
        Description = $_.Description
        ScopeName   = $_.ScopeName
    }
}

if ($report.Count -eq 0) {
    Write-Host "No Work Folders sync shares found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) Work Folders sync share record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
