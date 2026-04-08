<#
.SYNOPSIS
Reports on Microsoft 365 message center items.

.DESCRIPTION
This script summarizes Microsoft 365 service messages for operational review.

.EXAMPLE
.\Get-M365MessageCenterSummaryReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Authentication

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "ServiceMessage.Read.All" -NoWelcome

Write-Host "Retrieving message center items..." -ForegroundColor Cyan
$response = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/admin/serviceAnnouncement/messages" -OutputType HttpResponseMessage
$stream = $response.Content.ReadAsStreamAsync().Result
$reader = [System.IO.StreamReader]::new($stream)
$json = $reader.ReadToEnd()
$reader.Close()

$messages = ($json | ConvertFrom-Json).value

$report = foreach ($message in $messages) {
    [PSCustomObject]@{
        Id          = $message.id
        Title       = $message.title
        Service     = ($message.services -join ", ")
        Category    = $message.category
        Severity    = $message.severity
    }
}

Write-Host "Retrieved $($report.Count) message center item(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
