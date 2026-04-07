<#
.SYNOPSIS
Reports on Azure App Service plans across subscriptions.

.DESCRIPTION
This script retrieves Azure App Service plans across enabled subscriptions and
reports on SKU, capacity, scaling, and region details for inventory and
capacity planning.

.EXAMPLE
.\Get-AzureAppServicePlanReport.ps1

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

    $resourceGroups = Get-AzResourceGroup

    foreach ($resourceGroup in $resourceGroups) {
        $plans = Get-AzAppServicePlan -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue

        foreach ($plan in $plans) {
            [PSCustomObject]@{
                SubscriptionName     = $sub.Name
                ResourceGroup        = $resourceGroup.ResourceGroupName
                PlanName             = $plan.Name
                Location             = $plan.Location
                SkuName              = $plan.Sku.Name
                SkuTier              = $plan.Sku.Tier
                Capacity             = $plan.Sku.Capacity
                NumberOfWorkers      = $plan.NumberOfWorkers
                MaximumNumberOfWorkers = $plan.MaximumNumberOfWorkers
                PerSiteScaling       = $plan.PerSiteScaling
                Reserved             = $plan.Reserved
            }
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No App Service plans found." -ForegroundColor Yellow
}
else {
    $reserved = ($report | Where-Object { $_.Reserved }).Count
    $perSiteScaling = ($report | Where-Object { $_.PerSiteScaling }).Count

    Write-Host "Retrieved $($report.Count) App Service plan(s)." -ForegroundColor Green
    Write-Host "  Linux reserved plans: $reserved" -ForegroundColor Yellow
    Write-Host "  Per-site scaling enabled: $perSiteScaling" -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
