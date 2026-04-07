<#
.SYNOPSIS
Reports on Azure storage accounts and their configuration.

.DESCRIPTION
This script retrieves Azure storage accounts across subscriptions and reports
on their configuration including access tier, replication, HTTPS enforcement,
and public access settings for security and governance review.

.EXAMPLE
.\Get-AzureStorageAccountReport.ps1

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

#Requires -Module Az.Accounts
#Requires -Module Az.Storage

Write-Host "Connecting to Azure..." -ForegroundColor Cyan
Connect-AzAccount -ErrorAction Stop | Out-Null

$subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" }

$report = foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)..." -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $storageAccounts = Get-AzStorageAccount

    foreach ($sa in $storageAccounts) {
        [PSCustomObject]@{
            SubscriptionName     = $sub.Name
            ResourceGroup        = $sa.ResourceGroupName
            StorageAccountName   = $sa.StorageAccountName
            Location             = $sa.Location
            Kind                 = $sa.Kind
            SkuName              = $sa.Sku.Name
            AccessTier           = $sa.AccessTier
            HttpsOnly            = $sa.EnableHttpsTrafficOnly
            MinTlsVersion        = $sa.MinimumTlsVersion
            AllowBlobPublicAccess = $sa.AllowBlobPublicAccess
            NetworkDefaultAction = $sa.NetworkRuleSet.DefaultAction
            CreationTime         = $sa.CreationTime
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No storage accounts found." -ForegroundColor Yellow
}
else {
    $publicAccess = ($report | Where-Object { $_.AllowBlobPublicAccess -eq $true }).Count
    $noHttps = ($report | Where-Object { -not $_.HttpsOnly }).Count

    Write-Host "Retrieved $($report.Count) storage account(s)." -ForegroundColor Green
    if ($publicAccess -gt 0) { Write-Host "  WARNING: $publicAccess allow public blob access." -ForegroundColor Red }
    if ($noHttps -gt 0) { Write-Host "  WARNING: $noHttps do not enforce HTTPS." -ForegroundColor Red }
    $report | Format-Table -AutoSize
}
