<#
.SYNOPSIS
Reports on Azure resource group tags and compliance.

.DESCRIPTION
This script audits Azure resource groups and their tagging status,
identifying resource groups that are missing required tags for governance
and cost management.

.PARAMETER RequiredTags
Array of tag names that should be present on every resource group.

.EXAMPLE
.\Get-AzureTagComplianceReport.ps1 -RequiredTags "Environment", "Owner", "CostCenter"

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com

Disclaimer:
Test this script in a non-production environment before using it in production.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string[]]$RequiredTags = @("Environment", "Owner")
)

#Requires -Module Az.Accounts
#Requires -Module Az.Resources

Write-Host "Connecting to Azure..." -ForegroundColor Cyan
Connect-AzAccount -ErrorAction Stop | Out-Null

$subscriptions = Get-AzSubscription | Where-Object { $_.State -eq "Enabled" }

$report = foreach ($sub in $subscriptions) {
    Write-Host "Processing subscription: $($sub.Name)..." -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $resourceGroups = Get-AzResourceGroup

    foreach ($rg in $resourceGroups) {
        $missingTags = foreach ($tag in $RequiredTags) {
            if (-not $rg.Tags -or -not $rg.Tags.ContainsKey($tag)) { $tag }
        }

        [PSCustomObject]@{
            SubscriptionName  = $sub.Name
            ResourceGroup     = $rg.ResourceGroupName
            Location          = $rg.Location
            TagCount          = if ($rg.Tags) { $rg.Tags.Count } else { 0 }
            MissingTags       = if ($missingTags) { $missingTags -join ", " } else { "None" }
            Compliant         = if ($missingTags) { $false } else { $true }
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No resource groups found." -ForegroundColor Yellow
}
else {
    $nonCompliant = ($report | Where-Object { -not $_.Compliant }).Count
    Write-Host "Audited $($report.Count) resource group(s). Non-compliant: $nonCompliant" -ForegroundColor Green
    $report | Format-Table -AutoSize
}
