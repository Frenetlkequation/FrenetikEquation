<#
.SYNOPSIS
Exports Microsoft 365 license assignment information.

.DESCRIPTION
This script retrieves license assignment data from Microsoft 365 and produces
a report for administrative review, cost management, and auditing.

.EXAMPLE
.\Export-M365Licenses.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param ()

#Requires -Module Microsoft.Graph.Users

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All" -NoWelcome

Write-Host "Retrieving license information..." -ForegroundColor Cyan

$subscribedSkus = Get-MgSubscribedSku
$skuLookup = @{}
foreach ($sku in $subscribedSkus) {
    $skuLookup[$sku.SkuId] = $sku.SkuPartNumber
}

$users = Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, AccountEnabled, AssignedLicenses

$report = foreach ($user in $users) {
    if ($user.AssignedLicenses.Count -gt 0) {
        foreach ($license in $user.AssignedLicenses) {
            $skuName = $skuLookup[$license.SkuId]
            if (-not $skuName) { $skuName = $license.SkuId }

            [PSCustomObject]@{
                DisplayName       = $user.DisplayName
                UserPrincipalName = $user.UserPrincipalName
                AccountEnabled    = $user.AccountEnabled
                LicenseSku        = $skuName
            }
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No license assignments found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) license assignment(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
