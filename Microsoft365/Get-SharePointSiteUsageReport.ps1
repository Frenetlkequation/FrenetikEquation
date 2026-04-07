<#
.SYNOPSIS
Reports on SharePoint Online site usage.

.DESCRIPTION
This script retrieves SharePoint site usage detail from Microsoft Graph and
reports on storage usage, activity, and site health for governance review.

.PARAMETER Period
Reporting period to query. Valid values are D7, D30, D90, and D180.

.EXAMPLE
.\Get-SharePointSiteUsageReport.ps1 -Period D30

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

Write-Host "Retrieving SharePoint usage data for $Period..." -ForegroundColor Cyan

$response = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/reports/getSharePointSiteUsageDetail(period='$Period')" -OutputType HttpResponseMessage
$stream = $response.Content.ReadAsStreamAsync().Result
$reader = [System.IO.StreamReader]::new($stream)
$csvContent = $reader.ReadToEnd()
$reader.Close()

$data = $csvContent | ConvertFrom-Csv

$report = foreach ($row in $data) {
    $usedGB = if ($row.'Storage Used (Byte)') { [math]::Round([long]$row.'Storage Used (Byte)' / 1GB, 2) } else { 0 }
    $allocatedGB = if ($row.'Storage Allocated (Byte)') { [math]::Round([long]$row.'Storage Allocated (Byte)' / 1GB, 2) } else { 0 }

    [PSCustomObject]@{
        SiteUrl             = $row.'Site URL'
        OwnerPrincipalName  = $row.'Owner Principal Name'
        IsDeleted           = $row.'Is Deleted'
        LastActivityDate    = $row.'Last Activity Date'
        FileCount           = $row.'File Count'
        ActiveFileCount     = $row.'Active File Count'
        UsedGB              = $usedGB
        AllocatedGB         = $allocatedGB
        UsedPercent         = if ($allocatedGB -gt 0) { [math]::Round(($usedGB / $allocatedGB) * 100, 1) } else { 0 }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No SharePoint usage data found." -ForegroundColor Yellow
}
else {
    $deletedSites = ($report | Where-Object { $_.IsDeleted -eq "True" }).Count
    $totalUsedGB = [math]::Round(($report | Measure-Object -Property UsedGB -Sum).Sum, 2)

    Write-Host "Retrieved data for $($report.Count) SharePoint site(s). Total used: $totalUsedGB GB" -ForegroundColor Green
    if ($deletedSites -gt 0) {
        Write-Host "  Deleted sites included in report: $deletedSites" -ForegroundColor Yellow
    }
    $report | Sort-Object UsedGB -Descending | Format-Table -AutoSize
}
