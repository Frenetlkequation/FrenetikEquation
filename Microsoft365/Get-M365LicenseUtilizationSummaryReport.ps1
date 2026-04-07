<#
.SYNOPSIS
Reports on Microsoft 365 license utilization.

.DESCRIPTION
This script compares subscribed SKU capacity with assigned licenses to
summarize tenant-wide Microsoft 365 license utilization.

.EXAMPLE
.\Get-M365LicenseUtilizationSummaryReport.ps1

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

#Requires -Module Microsoft.Graph.Users

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All" -NoWelcome

Write-Host "Retrieving license utilization data..." -ForegroundColor Cyan

try {
    $skus = Get-MgSubscribedSku
    $users = Get-MgUser -All -Property AssignedLicenses
}
catch {
    Write-Warning "Failed to retrieve license data: $_"
    $skus = @()
    $users = @()
}

$report = foreach ($sku in $skus) {
    $assignedCount = ($users | Where-Object { $_.AssignedLicenses.SkuId -contains $sku.SkuId }).Count
    [PSCustomObject]@{
        SkuPartNumber  = $sku.SkuPartNumber
        SkuId          = $sku.SkuId
        ConsumedUnits   = $sku.ConsumedUnits
        PrepaidUnits    = $sku.PrepaidUnits.Enabled
        WarningUnits    = $sku.PrepaidUnits.Warning
        AvailableUnits  = [int]$sku.PrepaidUnits.Enabled - [int]$sku.ConsumedUnits
        AssignedUsers   = $assignedCount
    }
}

if ($report.Count -eq 0) {
    Write-Host "No license utilization data found." -ForegroundColor Yellow
}
else {
    $overAllocated = ($report | Where-Object { $_.AvailableUnits -lt 0 }).Count
    Write-Host "Retrieved $($report.Count) license SKU record(s)." -ForegroundColor Green
    if ($overAllocated -gt 0) {
        Write-Host "WARNING: $overAllocated SKU(s) appear over allocated." -ForegroundColor Red
    }
    $report | Sort-Object SkuPartNumber | Format-Table -AutoSize
}
