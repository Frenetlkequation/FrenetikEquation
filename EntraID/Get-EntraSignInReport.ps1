<#
.SYNOPSIS
Exports Entra ID sign-in activity report.

.DESCRIPTION
This script retrieves recent sign-in logs from Entra ID for security monitoring,
user activity review, and compliance auditing.

.PARAMETER Days
Number of days of sign-in history to retrieve. Default is 7.

.EXAMPLE
.\Get-EntraSignInReport.ps1 -Days 30

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [int]$Days = 7
)

#Requires -Module Microsoft.Graph.Reports

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "AuditLog.Read.All", "Directory.Read.All" -NoWelcome

$startDate = (Get-Date).AddDays(-$Days).ToString("yyyy-MM-ddTHH:mm:ssZ")

Write-Host "Retrieving sign-in logs from the last $Days day(s)..." -ForegroundColor Cyan

$signIns = Get-MgAuditLogSignIn -Filter "createdDateTime ge $startDate" -All |
    Select-Object UserDisplayName, UserPrincipalName, AppDisplayName, IpAddress,
        @{Name = "Location"; Expression = { "$($_.Location.City), $($_.Location.CountryOrRegion)" }},
        @{Name = "Status"; Expression = { if ($_.Status.ErrorCode -eq 0) { "Success" } else { "Failed" } }},
        @{Name = "ErrorCode"; Expression = { $_.Status.ErrorCode }},
        @{Name = "FailureReason"; Expression = { $_.Status.FailureReason }},
        CreatedDateTime,
        ConditionalAccessStatus |
    Sort-Object CreatedDateTime -Descending

if ($signIns.Count -eq 0) {
    Write-Host "No sign-in logs found." -ForegroundColor Yellow
}
else {
    $failed = ($signIns | Where-Object { $_.Status -eq "Failed" }).Count
    Write-Host "Retrieved $($signIns.Count) sign-in record(s). Failed: $failed" -ForegroundColor Green
    $signIns | Format-Table -AutoSize
}
