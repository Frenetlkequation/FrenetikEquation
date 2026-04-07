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
