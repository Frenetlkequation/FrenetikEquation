<#
.SYNOPSIS
Reports on OneDrive for Business usage across the tenant.

.DESCRIPTION
This script retrieves OneDrive storage usage per user for capacity
planning, governance, and identifying inactive or over-utilized accounts.

.EXAMPLE
.\Get-OneDriveUsageReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Reports

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Reports.Read.All" -NoWelcome

Write-Host "Retrieving OneDrive usage data..." -ForegroundColor Cyan

$reportContent = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/reports/getOneDriveUsageAccountDetail(period='D30')" -OutputType HttpResponseMessage
$stream = $reportContent.Content.ReadAsStreamAsync().Result
$reader = [System.IO.StreamReader]::new($stream)
$csvContent = $reader.ReadToEnd()
$reader.Close()

$data = $csvContent | ConvertFrom-Csv

$report = foreach ($row in $data) {
    $usedGB = if ($row.'Storage Used (Byte)') { [math]::Round([long]$row.'Storage Used (Byte)' / 1GB, 2) } else { 0 }
    $allocatedGB = if ($row.'Storage Allocated (Byte)') { [math]::Round([long]$row.'Storage Allocated (Byte)' / 1GB, 2) } else { 0 }

    [PSCustomObject]@{
        UserPrincipalName = $row.'Owner Principal Name'
        DisplayName       = $row.'Owner Display Name'
        SiteURL           = $row.'Site URL'
        UsedGB            = $usedGB
        AllocatedGB       = $allocatedGB
        UsedPercent       = if ($allocatedGB -gt 0) { [math]::Round(($usedGB / $allocatedGB) * 100, 1) } else { 0 }
        FileCount         = $row.'File Count'
        ActiveFileCount   = $row.'Active File Count'
        LastActivityDate  = $row.'Last Activity Date'
        IsDeleted         = $row.'Is Deleted'
    }
}

if ($report.Count -eq 0) {
    Write-Host "No OneDrive usage data found." -ForegroundColor Yellow
}
else {
    $totalUsedGB = [math]::Round(($report | Measure-Object -Property UsedGB -Sum).Sum, 2)
    Write-Host "Retrieved data for $($report.Count) OneDrive account(s). Total used: $totalUsedGB GB" -ForegroundColor Green
    $report | Sort-Object UsedGB -Descending | Format-Table -AutoSize
}
