<#
.SYNOPSIS
Reports on Microsoft 365 sign-in risk.

.DESCRIPTION
This script inventories sign-in risk detections for security review.

.EXAMPLE
.\Get-M365SignInRiskSummaryReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Identity.SignIns

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "IdentityRiskEvent.Read.All", "AuditLog.Read.All" -NoWelcome

Write-Host "Retrieving risk detections..." -ForegroundColor Cyan
$detections = Get-MgRiskDetection -All -ErrorAction SilentlyContinue

$report = foreach ($detection in $detections) {
    [PSCustomObject]@{
        Id         = $detection.Id
        RiskLevel  = $detection.RiskLevel
        RiskState  = $detection.RiskState
        User       = $detection.UserPrincipalName
        Activity   = $detection.Activity
    }
}

Write-Host "Retrieved $($report.Count) risk detection record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
