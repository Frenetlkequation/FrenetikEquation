<#
.SYNOPSIS
Reports on print job queues.

.DESCRIPTION
This script inventories queued print jobs for print service monitoring.

.EXAMPLE
.\Get-PrintJobQueueReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied.
    Use at your own risk and validate it in a non-production environment before deployment.
#>

[CmdletBinding()]
param ()

Write-Host "Retrieving print job queue information..." -ForegroundColor Cyan

$report = Get-PrintJob -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        PrinterName = $_.PrinterName
        ID          = $_.ID
        DocumentName = $_.DocumentName
        JobStatus   = $_.JobStatus
        SubmittedTime = $_.SubmittedTime
    }
}

if ($report.Count -eq 0) {
    Write-Host "No print jobs found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) print job record(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
