<#
.SYNOPSIS
Reports on Azure load balancers across subscriptions.

.DESCRIPTION
This script retrieves Azure load balancers across enabled subscriptions and
reports on SKU, frontend configuration, backend pool count, and rule counts
for network inventory and review.

.EXAMPLE
.\Get-AzureLoadBalancerReport.ps1

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
#Requires -Module Az.Network

Write-Host "Connecting to Azure..." -ForegroundColor Cyan
Connect-AzAccount -ErrorAction Stop | Out-Null

$subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" }

$report = foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)..." -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $resourceGroups = Get-AzResourceGroup

    foreach ($resourceGroup in $resourceGroups) {
        $loadBalancers = Get-AzLoadBalancer -ResourceGroupName $resourceGroup.ResourceGroupName -ErrorAction SilentlyContinue

        foreach ($loadBalancer in $loadBalancers) {
            $frontends = @($loadBalancer.FrontendIpConfigurations)

            [PSCustomObject]@{
                SubscriptionName = $sub.Name
                ResourceGroup    = $resourceGroup.ResourceGroupName
                LoadBalancerName = $loadBalancer.Name
                Location         = $loadBalancer.Location
                SkuName          = $loadBalancer.Sku.Name
                FrontendCount    = $frontends.Count
                BackendPoolCount  = @($loadBalancer.BackendAddressPools).Count
                ProbeCount       = @($loadBalancer.Probes).Count
                RuleCount        = @($loadBalancer.LoadBalancingRules).Count
                NatRuleCount     = @($loadBalancer.InboundNatRules).Count
                OutboundRuleCount = @($loadBalancer.OutboundRules).Count
                IsInternal       = [bool]($frontends | Where-Object { $_.PrivateIpAddress })
            }
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No load balancers found." -ForegroundColor Yellow
}
else {
    $internal = ($report | Where-Object { $_.IsInternal }).Count
    $public = ($report | Where-Object { -not $_.IsInternal }).Count

    Write-Host "Retrieved $($report.Count) load balancer(s)." -ForegroundColor Green
    Write-Host "  Internal: $internal" -ForegroundColor Yellow
    Write-Host "  Public: $public" -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
