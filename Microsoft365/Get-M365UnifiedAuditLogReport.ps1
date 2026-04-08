<#
.SYNOPSIS
Reports on Microsoft 365 unified audit log activity.

.DESCRIPTION
This script summarizes directory audit activity for compliance review.

.EXAMPLE
.\Get-M365UnifiedAuditLogReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param (
    [Parameter()]
    [int]$Days = 7
)

#Requires -Module Microsoft.Graph.Identity.SignIns

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "AuditLog.Read.All", "Directory.Read.All" -NoWelcome

$startDate = (Get-Date).AddDays(-$Days).ToString("yyyy-MM-ddTHH:mm:ssZ")

Write-Host "Retrieving unified audit data..." -ForegroundColor Cyan
$audits = Get-MgAuditLogDirectoryAudit -Filter "activityDateTime ge $startDate" -All -ErrorAction SilentlyContinue

$report = foreach ($audit in $audits) {
    [PSCustomObject]@{
        ActivityDateTime    = $audit.ActivityDateTime
        ActivityDisplayName = $audit.ActivityDisplayName
        Category            = $audit.Category
        Result              = $audit.Result
    }
}

Write-Host "Retrieved $($report.Count) unified audit record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
