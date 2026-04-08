<#
.SYNOPSIS
Reports on file server quotas.

.DESCRIPTION
This script inventories File Server Resource Manager quotas for capacity and governance review.

.EXAMPLE
.\Get-FileServerQuotaReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

#Requires -Module FileServerResourceManager

Write-Host "Retrieving file server quotas..." -ForegroundColor Cyan

$report = Get-FsrmQuota -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Path        = $_.Path
        Description = $_.Description
        SoftLimit   = $_.SoftLimit
        Threshold   = $_.Threshold
        Used        = $_.Usage
    }
}

if ($report.Count -eq 0) {
    Write-Host "No file server quotas found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) file server quota record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
