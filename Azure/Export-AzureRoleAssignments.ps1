<#
.SYNOPSIS
Exports Azure role assignment information for RBAC review.

.DESCRIPTION
This script retrieves Azure role assignments across subscriptions and produces
a report for security auditing and RBAC review purposes.

.EXAMPLE
.\Export-AzureRoleAssignments.ps1

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

    $assignments = Get-AzRoleAssignment

    foreach ($assignment in $assignments) {
        [PSCustomObject]@{
            SubscriptionName   = $sub.Name
            DisplayName        = $assignment.DisplayName
            SignInName         = $assignment.SignInName
            RoleDefinitionName = $assignment.RoleDefinitionName
            Scope              = $assignment.Scope
            ObjectType         = $assignment.ObjectType
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "No role assignments found." -ForegroundColor Yellow
}
else {
    Write-Host "Retrieved $($report.Count) role assignment(s) across $($subscriptions.Count) subscription(s)." -ForegroundColor Green
    $report | Format-Table -AutoSize
}
