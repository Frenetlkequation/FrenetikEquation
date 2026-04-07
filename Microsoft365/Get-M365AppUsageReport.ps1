<#
.SYNOPSIS
Reports on Microsoft 365 app usage.

.DESCRIPTION
This script summarizes Microsoft 365 usage reports for Exchange, OneDrive,
SharePoint, and Teams so administrators can review tenant adoption trends.

.PARAMETER Period
Reporting period to query. Valid values are D7, D30, D90, and D180.

.EXAMPLE
.\Get-M365AppUsageReport.ps1 -Period D30

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
param (
    [Parameter()]
    [ValidateSet("D7", "D30", "D90", "D180")]
    [string]$Period = "D30"
)

#Requires -Module Microsoft.Graph.Reports

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Reports.Read.All" -NoWelcome

Write-Host "Retrieving Microsoft 365 usage data for $Period..." -ForegroundColor Cyan

$endpoints = @(
    @{ Name = "Exchange"; Uri = "https://graph.microsoft.com/v1.0/reports/getEmailActivityUserDetail(period='$Period')" }
    @{ Name = "OneDrive"; Uri = "https://graph.microsoft.com/v1.0/reports/getOneDriveUsageAccountDetail(period='$Period')" }
    @{ Name = "SharePoint"; Uri = "https://graph.microsoft.com/v1.0/reports/getSharePointSiteUsageDetail(period='$Period')" }
    @{ Name = "Teams"; Uri = "https://graph.microsoft.com/v1.0/reports/getTeamsUserActivityUserDetail(period='$Period')" }
)

$report = foreach ($endpoint in $endpoints) {
    try {
        $response = Invoke-MgGraphRequest -Method GET -Uri $endpoint.Uri -OutputType HttpResponseMessage
        $stream = $response.Content.ReadAsStreamAsync().Result
        $reader = [System.IO.StreamReader]::new($stream)
        $csvContent = $reader.ReadToEnd()
        $reader.Close()
        $data = $csvContent | ConvertFrom-Csv

        [PSCustomObject]@{
            ReportName   = $endpoint.Name
            RecordCount   = $data.Count
            ActiveCount   = ($data | Where-Object { $_.'Last Activity Date' }).Count
            InactiveCount = ($data | Where-Object { -not $_.'Last Activity Date' }).Count
        }
    }
    catch {
        Write-Warning "Failed to retrieve $($endpoint.Name) usage data: $_"
    }
}

if ($report.Count -eq 0) {
    Write-Host "No Microsoft 365 usage data found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved Microsoft 365 usage summaries for $($report.Count) workload(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
