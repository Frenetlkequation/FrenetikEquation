<#
.SYNOPSIS
Reports on Azure cost by resource group.

.DESCRIPTION
This script queries consumption cost details for the selected date range and aggregates estimated spend by resource group for cost analysis.

.PARAMETER StartDate
The start date for the cost analysis range. Default is 30 days ago.

.PARAMETER EndDate
The end date for the cost analysis range. Default is today.
.EXAMPLE
.\Get-AzureCostByResourceGroupReport.ps1

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
    [datetime]$StartDate = (Get-Date).AddDays(-30),

    [Parameter()]
    [datetime]$EndDate = (Get-Date)
)

#Requires -Module Az.Accounts
#Requires -Module Az.Consumption

Write-Host "Connecting to Azure..." -ForegroundColor Cyan
Connect-AzAccount -ErrorAction Stop | Out-Null

$subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" }

$report = foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)..." -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $resources = Get-AzConsumptionUsageDetail -StartDate $StartDate -EndDate $EndDate -ErrorAction SilentlyContinue |
        Group-Object -Property ResourceGroup

    foreach ($resource in $resources) {
        $cost = ($resource.Group | Measure-Object -Property PretaxCost -Sum).Sum
        if (-not $cost) { $cost = ($resource.Group | Measure-Object -Property PreTaxCost -Sum).Sum }

        $estimatedCost = if ($null -ne $cost) { [double]$cost } else { 0 }

        [PSCustomObject]@{
            SubscriptionName = $sub.Name
            ResourceGroup    = if ($resource.Name) { $resource.Name } else { 'Unknown' }
            EstimatedCost    = [math]::Round($estimatedCost, 2)
            UsageRecords     = @($resource.Group).Count
            PeriodStart      = $StartDate
            PeriodEnd        = $EndDate
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No cost data found for the selected period." -ForegroundColor Yellow
}
else {
    $totalCost = ($report | Measure-Object -Property EstimatedCost -Sum).Sum
    $displayCost = if ($null -ne $totalCost) { [math]::Round([double]$totalCost, 2) } else { 0 }
    Write-Host "Retrieved $($report.Count) resource group cost record(s). Total estimated cost: $displayCost" -ForegroundColor Green
    $report | Format-Table -AutoSize
}
