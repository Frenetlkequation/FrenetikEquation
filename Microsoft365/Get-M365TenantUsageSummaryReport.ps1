<#
.SYNOPSIS
Reports on Microsoft 365 tenant usage summaries.

.DESCRIPTION
This script summarizes tenant workload usage across Microsoft 365.

.EXAMPLE
.\Get-M365TenantUsageSummaryReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet("D7", "D30", "D90", "D180")]
    [string]$Period = "D30"
)

#Requires -Module Microsoft.Graph.Reports

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Reports.Read.All" -NoWelcome

Write-Host "Retrieving usage summaries for $Period..." -ForegroundColor Cyan
$endpoints = @(
    @{ Name = "ActiveUsers"; Uri = "https://graph.microsoft.com/v1.0/reports/getOffice365ActiveUserDetail(period='$Period')" }
    @{ Name = "MailboxUsage"; Uri = "https://graph.microsoft.com/v1.0/reports/getMailboxUsageDetail(period='$Period')" }
    @{ Name = "SharePointSites"; Uri = "https://graph.microsoft.com/v1.0/reports/getSharePointSiteUsageDetail(period='$Period')" }
    @{ Name = "TeamsActivity"; Uri = "https://graph.microsoft.com/v1.0/reports/getTeamsUserActivityUserDetail(period='$Period')" }
)

$report = foreach ($endpoint in $endpoints) {
    try {
        $response = Invoke-MgGraphRequest -Method GET -Uri $endpoint.Uri -OutputType HttpResponseMessage
        $stream = $response.Content.ReadAsStreamAsync().Result
        $reader = [System.IO.StreamReader]::new($stream)
        $csv = $reader.ReadToEnd()
        $reader.Close()
        $rows = $csv | ConvertFrom-Csv

        [PSCustomObject]@{
            Workload   = $endpoint.Name
            RowCount   = $rows.Count
            ActiveCount = ($rows | Where-Object { $_.'Last Activity Date' }).Count
        }
    }
    catch {
        Write-Warning "Failed to retrieve $($endpoint.Name) usage data: $_"
    }
}

Write-Host "Retrieved usage summaries for $($report.Count) workload(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
