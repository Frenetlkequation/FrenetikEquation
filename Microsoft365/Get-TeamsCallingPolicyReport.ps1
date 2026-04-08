<#
.SYNOPSIS
Reports on Microsoft Teams calling policies.

.DESCRIPTION
This script inventories calling policies for Teams voice governance.

.EXAMPLE
.\Get-TeamsCallingPolicyReport.ps1

.NOTES
Author: FrenetikEquation
Website: www.frenetikequation.com
#>

[CmdletBinding()]
param ()

#Requires -Module MicrosoftTeams

Write-Host "Connecting to Microsoft Teams..." -ForegroundColor Cyan
Connect-MicrosoftTeams

Write-Host "Retrieving calling policies..." -ForegroundColor Cyan
$policies = Get-CsTeamsCallingPolicy

$report = foreach ($policy in $policies) {
    [PSCustomObject]@{
        Identity   = $policy.Identity
        Description = $policy.Description
        AllowPrivateCalling = $policy.AllowPrivateCalling
        BlockIncomingPstnCalls = $policy.BlockIncomingPstnCalls
    }
}

Write-Host "Retrieved $($report.Count) calling policy record(s)." -ForegroundColor Green
$report | Format-Table -AutoSize
