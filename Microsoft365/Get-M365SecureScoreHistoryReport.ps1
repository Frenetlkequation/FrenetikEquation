<#
.SYNOPSIS
Reports on Microsoft 365 secure score history.

.DESCRIPTION
This script retrieves secure score history for security trend review.

.EXAMPLE
.\Get-M365SecureScoreHistoryReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Authentication

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "SecurityEvents.Read.All" -NoWelcome

Write-Host "Retrieving secure scores..." -ForegroundColor Cyan
$response = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/security/secureScores" -OutputType HttpResponseMessage
$stream = $response.Content.ReadAsStreamAsync().Result
$reader = [System.IO.StreamReader]::new($stream)
$json = $reader.ReadToEnd()
$reader.Close()

$scores = ($json | ConvertFrom-Json).value

$report = foreach ($score in $scores) {
    [PSCustomObject]@{
        Id          = $score.id
        CreatedDate  = $score.createdDateTime
        CurrentScore = $score.currentScore
        MaxScore     = $score.maxScore
    }
}

Write-Host "Retrieved $($report.Count) secure score record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
