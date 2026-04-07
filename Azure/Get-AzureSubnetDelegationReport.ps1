<#
.SYNOPSIS
Reports on delegated Azure subnets.

.DESCRIPTION
This script scans virtual networks for delegated subnets and reports the delegation target for network governance and service planning.

.EXAMPLE
.\Get-AzureSubnetDelegationReport.ps1

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
#Requires -Module Az.Resources

Write-Host "Connecting to Azure..." -ForegroundColor Cyan
Connect-AzAccount -ErrorAction Stop | Out-Null

$subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" }

$report = foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)..." -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $resources = Get-AzResource -ResourceType "Microsoft.Network/virtualNetworks" -ErrorAction SilentlyContinue

    foreach ($resource in $resources) {
        foreach ($subnet in @($resource.Properties.subnets)) {
            if (@($subnet.delegations).Count -gt 0) {
                foreach ($delegation in @($subnet.delegations)) {
                    [PSCustomObject]@{
                        SubscriptionName = $sub.Name
                        ResourceGroup    = $resource.ResourceGroupName
                        VirtualNetwork   = $resource.Name
                        SubnetName       = $subnet.name
                        AddressPrefix    = (($subnet.addressPrefixes) -join ', ')
                        DelegationName   = $delegation.name
                        ServiceName      = $delegation.serviceName
                    }
                }
            }
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No delegated subnets found." -ForegroundColor Yellow
}
else {
    $delegated = ($report | Select-Object -ExpandProperty SubnetName -Unique).Count
    Write-Host "Retrieved $($report.Count) subnet delegation record(s) across $delegated delegated subnet(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
