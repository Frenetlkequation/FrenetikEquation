<#
.SYNOPSIS
Reports on Microsoft Teams tenant dial plans.

.DESCRIPTION
This script inventories dial plans for voice routing governance.

.EXAMPLE
.\Get-TeamsTenantDialPlanReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving tenant dial plans..." -ForegroundColor Cyan
$plans = Get-CsTenantDialPlan

$report = foreach ($plan in $plans) {
    [PSCustomObject]@{
        Identity    = $plan.Identity
        Description = $plan.Description
        SimpleName  = $plan.SimpleName
    }
}

Write-Host "Retrieved $($report.Count) tenant dial plan record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
