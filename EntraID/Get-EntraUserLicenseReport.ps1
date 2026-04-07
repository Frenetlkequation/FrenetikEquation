<#
.SYNOPSIS
Reports on Entra ID user license assignments.

.DESCRIPTION
This script retrieves Microsoft Entra user license assignments and maps SKU IDs
to SKU names for reporting, inventory, and license governance.

.EXAMPLE
.\Get-EntraUserLicenseReport.ps1

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

Write-Host "Retrieving Microsoft Entra license data..." -ForegroundColor Cyan

$skuLookup = @{}
foreach ($sku in (Get-MgSubscribedSku)) {
    $skuLookup[$sku.SkuId] = $sku.SkuPartNumber
}

$users = Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, AccountEnabled, Department, JobTitle, UsageLocation, AssignedLicenses

$report = foreach ($user in $users) {
    if ($user.AssignedLicenses.Count -eq 0) {
        continue
    }

    foreach ($license in $user.AssignedLicenses) {
        $skuName = if ($skuLookup.ContainsKey($license.SkuId)) { $skuLookup[$license.SkuId] } else { $license.SkuId }

        [PSCustomObject]@{
            DisplayName       = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            AccountEnabled    = $user.AccountEnabled
            Department        = $user.Department
            JobTitle          = $user.JobTitle
            UsageLocation     = $user.UsageLocation
            LicenseSku        = $skuName
            LicenseSkuId      = $license.SkuId
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No user license assignments found." -ForegroundColor Yellow
}
else {
    $licensedUsers = ($report | Select-Object -ExpandProperty UserPrincipalName -Unique).Count
    $skuCount = ($report | Select-Object -ExpandProperty LicenseSku -Unique).Count

    Write-Host "Retrieved $($report.Count) license assignment record(s) across $licensedUsers user(s)." -ForegroundColor Green
    Write-Host "  Unique license SKUs: $skuCount" -ForegroundColor Yellow
    $report | Sort-Object DisplayName, LicenseSku | Format-Table -AutoSize
}
