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

Disclaimer:
Test this script in a non-production environment before using it in production.
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
