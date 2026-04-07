<#
.SYNOPSIS
Retrieves and reports on Azure resources across subscriptions.

.DESCRIPTION
This script queries Azure subscriptions for resources and produces
an inventory report for administrative review and auditing.

.EXAMPLE
.\Get-AzureResourcesReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
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

    $resources = Get-AzResource

    foreach ($resource in $resources) {
        [PSCustomObject]@{
            SubscriptionName = $sub.Name
            ResourceGroup    = $resource.ResourceGroupName
            ResourceName     = $resource.Name
            ResourceType     = $resource.ResourceType
            Location         = $resource.Location
            Tags             = ($resource.Tags | ConvertTo-Json -Compress -ErrorAction SilentlyContinue)
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No resources found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) resource(s) across $($subscriptions.Count) subscription(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
