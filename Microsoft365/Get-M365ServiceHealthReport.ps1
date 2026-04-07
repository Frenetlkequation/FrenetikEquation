<#
.SYNOPSIS
Reports on Microsoft 365 service health status.

.DESCRIPTION
This script retrieves Microsoft 365 service health overview data and active
service issues from Microsoft Graph for operational and support review.

.EXAMPLE
.\Get-M365ServiceHealthReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

LEGAL DISCLAIMER:
    This script is provided "AS IS" without warranty of any kind, express or implied,
    including but not limited to the warranties of merchantability, fitness for a
    particular purpose, and noninfringement.

    In no event shall the authors, contributors, or copyright holders (FrenetikEquation)
    be liable for any claim, damages, or other liability, whether in an action of
    contract, tort, or otherwise, arising from, out of, or in connection with this
    script or the use or other dealings in this script. This includes, without
    limitation, any direct, indirect, incidental, special, exemplary, or consequential
    damages, including but not limited to loss of data, loss of revenue, business
    interruption, or damage to systems.

    USE AT YOUR OWN RISK. You are solely responsible for testing this script in a
    non-production environment before deploying to any production system. The user
    assumes all responsibility and risk for the use of this script. It is strongly
    recommended that you review, understand, and validate the script logic before
    execution.

    By using this script, you acknowledge and agree to these terms. If you do not
    agree, do not use this script. Refer to the LICENSE file in the root of this
    repository for the full license terms.
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Authentication

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "ServiceMessage.Read.All" -NoWelcome

Write-Host "Retrieving Microsoft 365 service health data..." -ForegroundColor Cyan

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
        ServiceName      = $service.service
        Status           = $service.status
        IssueCount       = $serviceIssues.Count
        HasOpenIssues    = if ($serviceIssues.Count -gt 0) { $true } else { $false }
        LatestIssueTitle = if ($serviceIssues.Count -gt 0) { ($serviceIssues | Select-Object -First 1).title } else { "None" }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No Microsoft 365 service health data found." -ForegroundColor Yellow
}
else {
    $degraded = ($report | Where-Object { $_.Status -ne "serviceOperational" }).Count
    $openIssues = ($report | Where-Object { $_.HasOpenIssues }).Count

    Write-Host "Retrieved $($report.Count) service health record(s)." -ForegroundColor Green
    Write-Host "  Services with open issues: $openIssues" -ForegroundColor Yellow
    if ($degraded -gt 0) {
        Write-Host "WARNING: $degraded service(s) are not in a fully operational state." -ForegroundColor Red
    }
    $report | Sort-Object Status, ServiceName | Format-Table -AutoSize
}
