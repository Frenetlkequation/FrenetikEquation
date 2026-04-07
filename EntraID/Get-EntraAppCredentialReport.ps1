<#
.SYNOPSIS
Reports on Entra ID application registrations and their credential expiry.

.DESCRIPTION
This script retrieves Entra ID application registrations and checks for
expiring or expired client secrets and certificates. Useful for proactive
credential management and avoiding service outages.

.PARAMETER DaysUntilExpiry
Number of days to look ahead for expiring credentials. Default is 30.

.EXAMPLE
.\Get-EntraAppCredentialReport.ps1 -DaysUntilExpiry 60

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

#Requires -Module Microsoft.Graph.Applications

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "Application.Read.All" -NoWelcome

Write-Host "Retrieving Entra ID application registrations..." -ForegroundColor Cyan

$apps = Get-MgApplication -All -Property Id, DisplayName, AppId, PasswordCredentials, KeyCredentials

$today = Get-Date
$thresholdDate = $today.AddDays($DaysUntilExpiry)

$report = foreach ($app in $apps) {
    foreach ($secret in $app.PasswordCredentials) {
        $status = if ($secret.EndDateTime -lt $today) { "Expired" }
                  elseif ($secret.EndDateTime -lt $thresholdDate) { "Expiring Soon" }
                  else { "Valid" }

        [PSCustomObject]@{
            AppName        = $app.DisplayName
            AppId          = $app.AppId
            CredentialType = "Client Secret"
            Description    = $secret.DisplayName
            StartDate      = $secret.StartDateTime
            EndDate        = $secret.EndDateTime
            DaysRemaining  = [math]::Round(($secret.EndDateTime - $today).TotalDays, 0)
            Status         = $status
        }
    }

    foreach ($cert in $app.KeyCredentials) {
        $status = if ($cert.EndDateTime -lt $today) { "Expired" }
                  elseif ($cert.EndDateTime -lt $thresholdDate) { "Expiring Soon" }
                  else { "Valid" }

        [PSCustomObject]@{
            AppName        = $app.DisplayName
            AppId          = $app.AppId
            CredentialType = "Certificate"
            Description    = $cert.DisplayName
            StartDate      = $cert.StartDateTime
            EndDate        = $cert.EndDateTime
            DaysRemaining  = [math]::Round(($cert.EndDateTime - $today).TotalDays, 0)
            Status         = $status
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No application credentials found." -ForegroundColor Yellow
}
else {
    $expired = ($report | Where-Object { $_.Status -eq "Expired" }).Count
    $expiringSoon = ($report | Where-Object { $_.Status -eq "Expiring Soon" }).Count

    Write-Host "Found $($report.Count) credential(s) across $($apps.Count) application(s)." -ForegroundColor Green
    Write-Host "  Expired: $expired" -ForegroundColor Red
    Write-Host "  Expiring within $DaysUntilExpiry days: $expiringSoon" -ForegroundColor Yellow
    $report | Sort-Object DaysRemaining | Format-Table -AutoSize
}
