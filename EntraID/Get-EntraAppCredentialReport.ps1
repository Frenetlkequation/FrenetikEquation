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
