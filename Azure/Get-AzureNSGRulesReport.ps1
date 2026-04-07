<#
.SYNOPSIS
Reports on Azure Network Security Group rules.

.DESCRIPTION
This script retrieves and reports on NSG rules across Azure subscriptions,
highlighting inbound rules that allow broad access for security review.

.EXAMPLE
.\Get-AzureNSGRulesReport.ps1

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

    $nsgs = Get-AzNetworkSecurityGroup

    foreach ($nsg in $nsgs) {
        foreach ($rule in $nsg.SecurityRules) {
            $isOpenInbound = ($rule.Direction -eq "Inbound" -and
                              $rule.Access -eq "Allow" -and
                              $rule.SourceAddressPrefix -in @("*", "0.0.0.0/0", "Internet"))

            [PSCustomObject]@{
                SubscriptionName     = $sub.Name
                ResourceGroup        = $nsg.ResourceGroupName
                NSGName              = $nsg.Name
                RuleName             = $rule.Name
                Priority             = $rule.Priority
                Direction            = $rule.Direction
                Access               = $rule.Access
                Protocol             = $rule.Protocol
                SourceAddress        = $rule.SourceAddressPrefix -join ", "
                DestinationPort      = $rule.DestinationPortRange -join ", "
                OpenInboundFromAny   = $isOpenInbound
            }
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No NSG rules found." -ForegroundColor Yellow
}
else {
    $openRules = ($report | Where-Object { $_.OpenInboundFromAny }).Count
    Write-Host "Retrieved $($report.Count) NSG rule(s). Open inbound from any: $openRules" -ForegroundColor Green
    if ($openRules -gt 0) {
        Write-Host "WARNING: $openRules rule(s) allow inbound traffic from any source." -ForegroundColor Red
    }
    $report | Format-Table -AutoSize
}
