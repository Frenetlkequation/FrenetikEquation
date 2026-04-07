<#
.SYNOPSIS
Reports on Azure App Service applications.

.DESCRIPTION
This script retrieves Azure App Service web apps across subscriptions and
reports on state, HTTPS enforcement, identity configuration, and hosting plan
details for inventory and governance review.

.EXAMPLE
.\Get-AzureAppServiceReport.ps1

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
#Requires -Module Az.Websites

Write-Host "Connecting to Azure..." -ForegroundColor Cyan
Connect-AzAccount -ErrorAction Stop | Out-Null

$subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" }

$report = foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)..." -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $webApps = Get-AzWebApp

    foreach ($app in $webApps) {
        [PSCustomObject]@{
            SubscriptionName = $sub.Name
            ResourceGroup    = $app.ResourceGroup
            AppName          = $app.Name
            Kind             = $app.Kind
            Location         = $app.Location
            State            = $app.State
            DefaultHostName  = $app.DefaultHostName
            AppServicePlan   = if ($app.ServerFarmId) { ($app.ServerFarmId -split "/")[-1] } else { "Unknown" }
            HttpsOnly        = $app.HttpsOnly
            ClientCertEnabled = $app.ClientCertEnabled
            ManagedIdentity  = if ($app.Identity -and $app.Identity.Type) { $app.Identity.Type } else { "None" }
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No App Service applications found." -ForegroundColor Yellow
}
else {
    $stopped = ($report | Where-Object { $_.State -ne "Running" }).Count
    $withoutIdentity = ($report | Where-Object { $_.ManagedIdentity -eq "None" }).Count
    $httpAllowed = ($report | Where-Object { -not $_.HttpsOnly }).Count

    Write-Host "Retrieved $($report.Count) App Service application(s)." -ForegroundColor Green
    if ($stopped -gt 0) { Write-Host "  Stopped or unavailable: $stopped" -ForegroundColor Yellow }
    if ($withoutIdentity -gt 0) { Write-Host "  Without managed identity: $withoutIdentity" -ForegroundColor Yellow }
    if ($httpAllowed -gt 0) { Write-Host "  WARNING: $httpAllowed do not enforce HTTPS-only access." -ForegroundColor Red }
    $report | Format-Table -AutoSize
}
