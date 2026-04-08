<#
.SYNOPSIS
Reports on Microsoft 365 audit log activity.

.DESCRIPTION
This script summarizes directory audit events for security review.

.EXAMPLE
.\Get-M365AuditLogSummaryReport.ps1

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

Write-Host "Retrieving audit logs from the last $Days day(s)..." -ForegroundColor Cyan
$events = Get-MgAuditLogDirectoryAudit -Filter "activityDateTime ge $startDate" -All -ErrorAction SilentlyContinue

$report = foreach ($event in $events) {
    [PSCustomObject]@{
        ActivityDateTime = $event.ActivityDateTime
        ActivityDisplayName = $event.ActivityDisplayName
        Category        = $event.Category
        InitiatedBy     = $event.InitiatedBy.User.UserPrincipalName
        Result          = $event.Result
    }
}

Write-Host "Retrieved $($report.Count) audit record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
