<#
.SYNOPSIS
Reports on Microsoft 365 service announcements.

.DESCRIPTION
This script inventories service announcement messages and issues.

.EXAMPLE
.\Get-M365ServiceAnnouncementReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Authentication

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "ServiceMessage.Read.All" -NoWelcome

Write-Host "Retrieving service announcements..." -ForegroundColor Cyan
$response = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/admin/serviceAnnouncement/issues" -OutputType HttpResponseMessage
$stream = $response.Content.ReadAsStreamAsync().Result
$reader = [System.IO.StreamReader]::new($stream)
$json = $reader.ReadToEnd()
$reader.Close()

$issues = ($json | ConvertFrom-Json).value

$report = foreach ($issue in $issues) {
    [PSCustomObject]@{
        Id          = $issue.id
        Title       = $issue.title
        Service     = ($issue.services -join ", ")
        Severity    = $issue.severity
        Status      = $issue.status
    }
}

Write-Host "Retrieved $($report.Count) service announcement issue record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
