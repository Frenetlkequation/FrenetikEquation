<#
.SYNOPSIS
Reports on Microsoft 365 security alerts.

.DESCRIPTION
This script summarizes Microsoft 365 security alerts for operational review.

.EXAMPLE
.\Get-M365SecurityAlertSummaryReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Authentication

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "SecurityEvents.Read.All" -NoWelcome

Write-Host "Retrieving security alerts..." -ForegroundColor Cyan
$response = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/security/alerts" -OutputType HttpResponseMessage
$stream = $response.Content.ReadAsStreamAsync().Result
$reader = [System.IO.StreamReader]::new($stream)
$json = $reader.ReadToEnd()
$reader.Close()

$alerts = ($json | ConvertFrom-Json).value

$report = foreach ($alert in $alerts) {
    [PSCustomObject]@{
        Id          = $alert.id
        Title       = $alert.title
        Severity    = $alert.severity
        Status      = $alert.status
        Category    = $alert.category
    }
}

Write-Host "Retrieved $($report.Count) security alert record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
