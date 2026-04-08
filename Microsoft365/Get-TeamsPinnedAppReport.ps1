<#
.SYNOPSIS
Reports on Microsoft Teams pinned app configuration.

.DESCRIPTION
This script inventories pinned app setup policy details for Teams review.

.EXAMPLE
.\Get-TeamsPinnedAppReport.ps1

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
        Identity   = $policy.Identity
        Description = $policy.Description
        PinnedApps = ($policy.Apps -join ", ")
    }
}

Write-Host "Retrieved $($report.Count) pinned app policy record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
