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

Disclaimer:
Test this script in a non-production environment before using it in production.
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
