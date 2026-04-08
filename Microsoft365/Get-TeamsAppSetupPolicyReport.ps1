<#
.SYNOPSIS
Reports on Microsoft Teams app setup policies.

.DESCRIPTION
This script inventories app setup policies and pinned app configuration.

.EXAMPLE
.\Get-TeamsAppSetupPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving app setup policies..." -ForegroundColor Cyan
$policies = Get-CsTeamsAppSetupPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Identity     = $policy.Identity
        Description  = $policy.Description
        AllowPinning = $policy.AllowPinning
        AppIds       = ($policy.Apps -join ", ")
    }
}

Write-Host "Retrieved $($report.Count) app setup policy record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
