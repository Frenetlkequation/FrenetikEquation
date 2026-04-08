<#
.SYNOPSIS
Reports on Microsoft Teams voice routing policies.

.DESCRIPTION
This script inventories voice routing policies for call routing governance.

.EXAMPLE
.\Get-TeamsVoiceRoutingPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving voice routing policies..." -ForegroundColor Cyan
$policies = Get-CsOnlineVoiceRoutingPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Identity   = $policy.Identity
        Description = $policy.Description
        RouteList  = ($policy.OnlinePstnUsages -join ", ")
    }
}

Write-Host "Retrieved $($report.Count) voice routing policy record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
