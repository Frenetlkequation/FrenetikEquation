<#
.SYNOPSIS
Reports on Microsoft 365 workload adoption.

.DESCRIPTION
This script summarizes tenant workload adoption trends using Graph reports.

.EXAMPLE
.\Get-M365WorkloadAdoptionReport.ps1 -Period D30

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

Write-Host "Retrieving workload adoption data for $Period..." -ForegroundColor Cyan
$endpoints = @(
    @{ Name = "ActiveUsers"; Uri = "https://graph.microsoft.com/v1.0/reports/getOffice365ActiveUserCounts(period='$Period')" }
    @{ Name = "EmailActivity"; Uri = "https://graph.microsoft.com/v1.0/reports/getEmailActivityCounts(period='$Period')" }
    @{ Name = "TeamsActivity"; Uri = "https://graph.microsoft.com/v1.0/reports/getTeamsUserActivityCounts(period='$Period')" }
    @{ Name = "OneDriveUsage"; Uri = "https://graph.microsoft.com/v1.0/reports/getOneDriveUsageAccountCounts(period='$Period')" }
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
            Workload = $endpoint.Name
            RowCount = $rows.Count
        }
    }
    catch {
        Write-Warning "Failed to retrieve $($endpoint.Name) adoption data: $_"
    }
}

Write-Host "Retrieved adoption summaries for $($report.Count) workload(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
