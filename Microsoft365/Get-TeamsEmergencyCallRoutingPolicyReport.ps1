<#
.SYNOPSIS
Reports on Microsoft Teams emergency call routing policies.

.DESCRIPTION
This script inventories emergency call routing policies for Teams voice review.

.EXAMPLE
.\Get-TeamsEmergencyCallRoutingPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving emergency call routing policies..." -ForegroundColor Cyan
$policies = Get-CsTeamsEmergencyCallRoutingPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Identity    = $policy.Identity
        Description = $policy.Description
        Enabled     = $policy.Enabled
    }
}

Write-Host "Retrieved $($report.Count) emergency call routing policy record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
