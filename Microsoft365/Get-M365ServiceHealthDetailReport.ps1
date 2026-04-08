<#
.SYNOPSIS
Reports on Microsoft 365 service health details.

.DESCRIPTION
This script inventories service health overviews and open issues.

.EXAMPLE
.\Get-M365ServiceHealthDetailReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Authentication

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "ServiceMessage.Read.All" -NoWelcome

Write-Host "Retrieving service health data..." -ForegroundColor Cyan
$healthResponse = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/admin/serviceAnnouncement/healthOverviews" -OutputType HttpResponseMessage
$healthStream = $healthResponse.Content.ReadAsStreamAsync().Result
$healthReader = [System.IO.StreamReader]::new($healthStream)
$healthJson = $healthReader.ReadToEnd()
$healthReader.Close()

$healthData = ($healthJson | ConvertFrom-Json).value

$issuesResponse = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/admin/serviceAnnouncement/issues" -OutputType HttpResponseMessage
$issuesStream = $issuesResponse.Content.ReadAsStreamAsync().Result
$issuesReader = [System.IO.StreamReader]::new($issuesStream)
$issuesJson = $issuesReader.ReadToEnd()
$issuesReader.Close()

$issueData = ($issuesJson | ConvertFrom-Json).value

$report = foreach ($service in $healthData) {
    $serviceIssues = @($issueData | Where-Object { $_.service -eq $service.service })
    [PSCustomObject]@{
        ServiceName   = $service.service
        Status        = $service.status
        IssueCount    = $serviceIssues.Count
        HasOpenIssues = $serviceIssues.Count -gt 0
    }
}

Write-Host "Retrieved $($report.Count) service health record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
