<#
.SYNOPSIS
Reports on Azure Key Vault secrets and certificate expiration.

.DESCRIPTION
This script audits Azure Key Vaults across subscriptions and checks for
expiring or expired secrets and certificates to prevent service outages
caused by credential expiry.

.PARAMETER DaysUntilExpiry
Number of days to look ahead for expiring items. Default is 30.

.EXAMPLE
.\Get-AzureKeyVaultExpiryReport.ps1 -DaysUntilExpiry 60

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [int]$DaysUntilExpiry = 30
)

#Requires -Module Az.Accounts
#Requires -Module Az.KeyVault

Write-Host "Connecting to Azure..." -ForegroundColor Cyan
Connect-AzAccount -ErrorAction Stop | Out-Null

$subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" }
$today = Get-Date
$thresholdDate = $today.AddDays($DaysUntilExpiry)

$report = foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)..." -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $vaults = Get-AzKeyVault

    foreach ($vault in $vaults) {
        $secrets = Get-AzKeyVaultSecret -VaultName $vault.VaultName -ErrorAction SilentlyContinue
        foreach ($secret in $secrets) {
            if ($secret.Expires) {
                $status = if ($secret.Expires -lt $today) { "Expired" }
                          elseif ($secret.Expires -lt $thresholdDate) { "Expiring Soon" }
                          else { "Valid" }

                [PSCustomObject]@{
                    SubscriptionName = $sub.Name
                    VaultName        = $vault.VaultName
                    ItemName         = $secret.Name
                    ItemType         = "Secret"
                    Enabled          = $secret.Enabled
                    Expires          = $secret.Expires
                    DaysRemaining    = [math]::Round(($secret.Expires - $today).TotalDays, 0)
                    Status           = $status
                }
            }
        }

        $certificates = Get-AzKeyVaultCertificate -VaultName $vault.VaultName -ErrorAction SilentlyContinue
        foreach ($cert in $certificates) {
            if ($cert.Expires) {
                $status = if ($cert.Expires -lt $today) { "Expired" }
                          elseif ($cert.Expires -lt $thresholdDate) { "Expiring Soon" }
                          else { "Valid" }

                [PSCustomObject]@{
                    SubscriptionName = $sub.Name
                    VaultName        = $vault.VaultName
                    ItemName         = $cert.Name
                    ItemType         = "Certificate"
                    Enabled          = $cert.Enabled
                    Expires          = $cert.Expires
                    DaysRemaining    = [math]::Round(($cert.Expires - $today).TotalDays, 0)
                    Status           = $status
                }
            }
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No Key Vault items with expiry dates found." -ForegroundColor Yellow
}
else {
    $expired = ($report | Where-Object { $_.Status -eq "Expired" }).Count
    $expiringSoon = ($report | Where-Object { $_.Status -eq "Expiring Soon" }).Count

    Write-Host "Found $($report.Count) item(s) with expiry dates." -ForegroundColor Green
    if ($expired -gt 0) { Write-Host "  Expired: $expired" -ForegroundColor Red }
    if ($expiringSoon -gt 0) { Write-Host "  Expiring within $DaysUntilExpiry days: $expiringSoon" -ForegroundColor Yellow }
    $report | Sort-Object DaysRemaining | Format-Table -AutoSize
}
